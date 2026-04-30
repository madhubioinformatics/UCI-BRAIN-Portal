#!/usr/bin/env Rscript
# =============================================================================
# UCI BRAIN Portal — Bulk RNA-seq DESeq2 Pipeline
# Processes AMP-AD (ROSMAP/Mayo/MSBB) and TCGA brain data
#
# Author: Madhu Sudhana Saddala
# Institution: UCI MIND Institute, University of California, Irvine
# Contact: vswarup@uci.edu
# =============================================================================

suppressPackageStartupMessages({
  library(DESeq2)
  library(dplyr)
  library(jsonlite)
  library(data.table)
})

# =============================================================================
# CONFIGURATION — Edit these paths after downloading data from Synapse
# =============================================================================
CONFIG <- list(
  # AMP-AD Harmonized RNA-seq (Synapse: syn21241740)
  ROSMAP_COUNTS   = "data/raw/ROSMAP_RNAseq_counts.tsv",
  ROSMAP_META     = "data/raw/ROSMAP_clinical.csv",

  # TCGA GBM + LGG (GDC Portal download)
  TCGA_GBM_COUNTS = "data/raw/TCGA_GBM_htseq_counts.tsv",
  TCGA_LGG_COUNTS = "data/raw/TCGA_LGG_htseq_counts.tsv",
  TCGA_META       = "data/raw/TCGA_clinical.tsv",

  # GTEx Brain (gtexportal.org)
  GTEX_TPM        = "data/raw/GTEx_Analysis_v10_gene_tpm.gct.gz",
  GTEX_META       = "data/raw/GTEx_SampleAttributes.txt",

  # Output directory
  OUTPUT_DIR      = "data/processed/bulk_rnaseq/",
  JSON_OUTPUT_DIR = "data/genes/"
)

dir.create(CONFIG$OUTPUT_DIR,      showWarnings = FALSE, recursive = TRUE)
dir.create(CONFIG$JSON_OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

#' Run DESeq2 on a counts matrix with disease vs control comparison
#'
#' @param counts  Raw count matrix (genes x samples)
#' @param meta    Sample metadata with 'condition' column (AD/control)
#' @param covars  Covariate formula string (e.g., "~ condition + age + sex")
#' @param dataset Dataset name for output labeling
#' @param disorder Disorder name (e.g., "AD", "GBM")
#' @return Data frame with DESeq2 results + per-group summary stats
run_deseq2 <- function(counts, meta, covars = "~ condition", dataset, disorder) {

  message("Running DESeq2: ", dataset, " — ", disorder,
          " (", sum(meta$condition == "Disease"), " disease / ",
          sum(meta$condition == "Control"), " control)")

  # Build DESeqDataSet
  dds <- DESeqDataSetFromMatrix(
    countData = round(counts[, meta$sample_id]),
    colData   = meta,
    design    = as.formula(covars)
  )

  # Filter low-count genes (at least 10 counts in 10% of samples)
  min_samples <- max(3, ncol(counts) * 0.10)
  keep        <- rowSums(counts(dds) >= 10) >= min_samples
  dds         <- dds[keep, ]
  message("  Retained ", sum(keep), " / ", nrow(counts), " genes after filtering")

  # Run DESeq2
  dds <- DESeq(dds, parallel = FALSE, quiet = TRUE)

  # Extract results
  res <- results(dds,
                 contrast  = c("condition", "Disease", "Control"),
                 alpha     = 0.05,
                 pAdjustMethod = "BH")
  res_df <- as.data.frame(res) |>
    tibble::rownames_to_column("gene") |>
    dplyr::rename(log2FC = log2FoldChange, fdr = padj) |>
    dplyr::mutate(
      disorder  = disorder,
      dataset   = dataset,
      n_disease = sum(meta$condition == "Disease"),
      n_control = sum(meta$condition == "Control"),
      sig       = !is.na(fdr) & fdr < 0.05 & abs(log2FC) >= 1
    )

  # Add per-group expression values for box plots (up to 50 samples per group)
  norm_counts <- log2(counts(dds, normalized = TRUE) + 1)
  dis_idx     <- meta$condition == "Disease"
  ctrl_idx    <- meta$condition == "Control"

  gene_stats <- lapply(rownames(norm_counts), function(g) {
    dis_vals  <- norm_counts[g,  dis_idx]
    ctrl_vals <- norm_counts[g, ctrl_idx]

    # Sample up to 50 values per group for box plot jitter points
    n_samp    <- 50
    dis_samp  <- if (length(dis_vals)  > n_samp) sample(dis_vals,  n_samp) else dis_vals
    ctrl_samp <- if (length(ctrl_vals) > n_samp) sample(ctrl_vals, n_samp) else ctrl_vals

    data.frame(
      gene      = g,
      mean_dis  = round(mean(dis_vals),  3),
      sd_dis    = round(sd(dis_vals),    3),
      mean_ctrl = round(mean(ctrl_vals), 3),
      sd_ctrl   = round(sd(ctrl_vals),   3),
      # Comma-separated individual values for box plots
      vals_dis  = paste(round(dis_samp,  3), collapse = ","),
      vals_ctrl = paste(round(ctrl_samp, 3), collapse = ",")
    )
  }) |> dplyr::bind_rows()

  # Merge DE results with expression stats
  result <- res_df |>
    dplyr::left_join(gene_stats, by = "gene") |>
    dplyr::select(gene, disorder, dataset, log2FC, fdr, pvalue, baseMean,
                  n_disease, n_control, mean_dis, sd_dis, mean_ctrl, sd_ctrl,
                  vals_dis, vals_ctrl, sig)

  message("  Done: ", sum(!is.na(res_df$fdr) & res_df$fdr < 0.05),
          " FDR < 0.05 genes")
  return(result)
}


# =============================================================================
# ROSMAP — Alzheimer's Disease (after Synapse access approved)
# =============================================================================
process_rosmap_ad <- function() {
  if (!file.exists(CONFIG$ROSMAP_COUNTS)) {
    message("ROSMAP data not yet downloaded. Skipping.")
    message("Download from: https://www.synapse.org/#!Synapse:syn4164376")
    return(NULL)
  }

  counts <- fread(CONFIG$ROSMAP_COUNTS, data.table = FALSE) |>
    tibble::column_to_rownames("gene_id")

  meta <- read.csv(CONFIG$ROSMAP_META) |>
    dplyr::filter(diagnosis %in% c("AD", "control")) |>
    dplyr::mutate(
      condition = ifelse(diagnosis == "AD", "Disease", "Control"),
      condition = factor(condition, levels = c("Control", "Disease"))
    )

  # Align samples
  common_samples <- intersect(colnames(counts), meta$sample_id)
  counts_filt    <- counts[, common_samples]
  meta_filt      <- meta[meta$sample_id %in% common_samples, ]

  result <- run_deseq2(
    counts   = counts_filt,
    meta     = meta_filt,
    covars   = "~ condition + age_death + msex + pmi",  # standard ROSMAP covariates
    dataset  = "ROSMAP",
    disorder = "AD"
  )

  out_file <- file.path(CONFIG$OUTPUT_DIR, "ROSMAP_AD_DESeq2.csv")
  write.csv(result, out_file, row.names = FALSE)
  message("Saved: ", out_file)
  return(result)
}


# =============================================================================
# TCGA — Glioblastoma (GBM) — No DUC needed, download from GDC Portal
# =============================================================================
process_tcga_gbm <- function() {
  if (!file.exists(CONFIG$TCGA_GBM_COUNTS)) {
    message("TCGA-GBM data not yet downloaded. Skipping.")
    message("Download from: https://portal.gdc.cancer.gov/projects/TCGA-GBM")
    return(NULL)
  }

  counts <- fread(CONFIG$TCGA_GBM_COUNTS, data.table = FALSE) |>
    tibble::column_to_rownames("Ensembl_ID")

  meta <- read.delim(CONFIG$TCGA_META) |>
    dplyr::filter(project_id == "TCGA-GBM") |>
    dplyr::mutate(
      condition = ifelse(sample_type == "Solid Tissue Normal", "Control", "Disease"),
      condition = factor(condition, levels = c("Control", "Disease"))
    )

  common <- intersect(colnames(counts), meta$sample_id)
  result <- run_deseq2(
    counts   = counts[, common],
    meta     = meta[meta$sample_id %in% common, ],
    covars   = "~ condition + age_at_diagnosis + gender",
    dataset  = "TCGA",
    disorder = "GBM"
  )

  out_file <- file.path(CONFIG$OUTPUT_DIR, "TCGA_GBM_DESeq2.csv")
  write.csv(result, out_file, row.names = FALSE)
  message("Saved: ", out_file)
  return(result)
}


# =============================================================================
# COMBINE RESULTS AND GENERATE JSON FILES
# =============================================================================
generate_gene_jsons <- function(results_list) {
  # Combine all disorder results
  all_results <- dplyr::bind_rows(results_list)

  # Group by gene and create one JSON per gene
  genes <- unique(all_results$gene)
  message("Generating JSON files for ", length(genes), " genes...")

  pb <- txtProgressBar(min = 0, max = length(genes), style = 3)

  for (i in seq_along(genes)) {
    g        <- genes[i]
    gene_df  <- all_results[all_results$gene == g, ]

    gene_json <- list(bulk = list())

    for (j in seq_len(nrow(gene_df))) {
      row      <- gene_df[j, ]
      disorder <- row$disorder

      gene_json$bulk[[disorder]] <- list(
        log2FC    = round(row$log2FC, 3),
        fdr       = if (!is.na(row$fdr))    signif(row$fdr,    3) else NULL,
        pvalue    = if (!is.na(row$pvalue)) signif(row$pvalue, 3) else NULL,
        baseMean  = round(row$baseMean, 1),
        nDisease  = as.integer(row$n_disease),
        nControl  = as.integer(row$n_control),
        meanDis   = round(row$mean_dis,  3),
        sdDis     = round(row$sd_dis,    3),
        meanCtrl  = round(row$mean_ctrl, 3),
        sdCtrl    = round(row$sd_ctrl,   3),
        dataset   = row$dataset,
        valsDis   = as.numeric(strsplit(row$vals_dis,  ",")[[1]]),
        valsCtrl  = as.numeric(strsplit(row$vals_ctrl, ",")[[1]])
      )
    }

    json_file <- file.path(CONFIG$JSON_OUTPUT_DIR, paste0(g, ".json"))
    write(toJSON(gene_json, auto_unbox = TRUE, digits = 6), json_file)
    setTxtProgressBar(pb, i)
  }

  close(pb)
  message("\nJSON generation complete: ", length(genes), " files in ",
          CONFIG$JSON_OUTPUT_DIR)
}


# =============================================================================
# MAIN EXECUTION
# =============================================================================
message("=== UCI BRAIN Portal — Bulk RNA-seq Processing Pipeline ===")
message("Start time: ", Sys.time())

results <- list()

# Process each dataset (will skip if data not yet downloaded)
results$ROSMAP_AD  <- process_rosmap_ad()
results$TCGA_GBM   <- process_tcga_gbm()
# Add more: process_mayo_ad(), process_msbb_ad(), process_tcga_lgg(), etc.

# Remove NULLs (datasets not yet downloaded)
results <- Filter(Negate(is.null), results)

if (length(results) > 0) {
  generate_gene_jsons(results)
  message("\n✓ Pipeline complete. JSON files ready for portal integration.")
  message("  Next: Update portal fetchGeneData() to load from ./data/genes/")
} else {
  message("\n⚠ No data processed yet. Please download data from:")
  message("  AMP-AD: https://adknowledgeportal.synapse.org (Synapse ID: syn4164376)")
  message("  TCGA:   https://portal.gdc.cancer.gov/projects/TCGA-GBM")
  message("  GTEx:   https://gtexportal.org/home/downloads")
}

message("End time: ", Sys.time())
