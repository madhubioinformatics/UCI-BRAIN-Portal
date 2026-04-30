# Data Preprocessing Pipelines

This directory contains R and Python pipelines for processing real data sources
into the JSON format required by the UCI BRAIN portal.

## Pipelines

### bulk_rnaseq/
- `deseq2_pipeline.R` — DESeq2 differential expression for AMP-AD and TCGA data
- `gtex_normalization.R` — GTEx brain TPM normalization and region extraction

### scrna/
- `seurat_pipeline.R` — Seurat pseudobulk DE analysis from Allen Brain Cell Atlas
- `pseudobulk_de.R` — Cell-type specific differential expression

### proteomics/
- `limma_pipeline.R` — limma-voom for CPTAC and AMP-AD proteomics

### data_integration/
- `json_generator.py` — Converts processed TSV results to per-gene JSON files
  for portal consumption

## Data Sources

See `../data/README.md` for data access instructions and Synapse IDs.

## Requirements

```r
# R packages
install.packages(c("dplyr", "tidyr", "jsonlite", "data.table"))
BiocManager::install(c("DESeq2", "edgeR", "limma", "fgsea", "Seurat"))
```

```python
# Python packages
pip install synapseclient pandas numpy scipy anndata scanpy
```

## Status

- [ ] bulk_rnaseq/deseq2_pipeline.R — in development
- [ ] scrna/seurat_pipeline.R — in development  
- [ ] proteomics/limma_pipeline.R — in development
- [ ] data_integration/json_generator.py — in development
