#!/usr/bin/env python3
"""
UCI BRAIN Portal — JSON Data Generator
Converts processed DESeq2/limma results to per-gene JSON files
for portal consumption.

Author: Madhu Sudhana Saddala
Institution: UCI MIND Institute, University of California, Irvine
"""

import pandas as pd
import json
import os
import sys
from pathlib import Path

# ── Configuration ──────────────────────────────────────────────────────────────
INPUT_DIR  = Path("data/processed")
OUTPUT_DIR = Path("data/genes")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Map of processed CSV files to their module
DATA_FILES = {
    "bulk_rnaseq": [
        "bulk_rnaseq/ROSMAP_AD_DESeq2.csv",
        "bulk_rnaseq/TCGA_GBM_DESeq2.csv",
        "bulk_rnaseq/TCGA_LGG_DESeq2.csv",
        "bulk_rnaseq/Mayo_AD_DESeq2.csv",
        "bulk_rnaseq/MSBB_AD_DESeq2.csv",
        "bulk_rnaseq/PsychENCODE_SCZ_DESeq2.csv",
    ],
    "survival": [
        "survival/TCGA_GBM_KM.csv",
        "survival/TCGA_LGG_KM.csv",
    ],
}


def load_available_files(module: str) -> pd.DataFrame:
    """Load all available processed files for a module."""
    dfs = []
    for fname in DATA_FILES.get(module, []):
        fpath = INPUT_DIR / fname
        if fpath.exists():
            df = pd.read_csv(fpath)
            dfs.append(df)
            print(f"  ✓ Loaded {fname}: {len(df):,} rows")
        else:
            print(f"  ⚠ Not found (skip): {fname}")
    return pd.concat(dfs, ignore_index=True) if dfs else pd.DataFrame()


def safe_float(val, digits=3):
    """Convert to float safely, return None for NaN."""
    try:
        v = float(val)
        if pd.isna(v):
            return None
        return round(v, digits)
    except (TypeError, ValueError):
        return None


def parse_vals(val_str: str) -> list:
    """Parse comma-separated float string to list."""
    if pd.isna(val_str) or str(val_str).strip() == "":
        return []
    try:
        return [round(float(x), 3) for x in str(val_str).split(",") if x.strip()]
    except ValueError:
        return []


def build_gene_json(gene: str, bulk_df: pd.DataFrame) -> dict:
    """Build the complete JSON structure for a single gene."""
    gene_data = {"bulk": {}, "survival": {}}

    # ── Bulk RNA-seq ────────────────────────────────────────────────────────
    gene_bulk = bulk_df[bulk_df["gene"] == gene]
    for _, row in gene_bulk.iterrows():
        disorder = row["disorder"]
        gene_data["bulk"][disorder] = {
            "log2FC":   safe_float(row.get("log2FC")),
            "fdr":      safe_float(row.get("fdr"), digits=6),
            "pvalue":   safe_float(row.get("pvalue"), digits=6),
            "baseMean": safe_float(row.get("baseMean"), digits=1),
            "nDisease": int(row["n_disease"]) if pd.notna(row.get("n_disease")) else None,
            "nControl": int(row["n_control"]) if pd.notna(row.get("n_control")) else None,
            "meanDis":  safe_float(row.get("mean_dis")),
            "sdDis":    safe_float(row.get("sd_dis")),
            "meanCtrl": safe_float(row.get("mean_ctrl")),
            "sdCtrl":   safe_float(row.get("sd_ctrl")),
            "dataset":  str(row.get("dataset", "")),
            "valsDis":  parse_vals(row.get("vals_dis", "")),
            "valsCtrl": parse_vals(row.get("vals_ctrl", "")),
        }

    return gene_data


def generate_all_jsons():
    """Main function — generate one JSON per gene."""
    print("=== UCI BRAIN Portal — JSON Generator ===\n")

    # Load all available data
    print("Loading bulk RNA-seq data:")
    bulk_df = load_available_files("bulk_rnaseq")

    if bulk_df.empty:
        print("\n⚠  No processed data found.")
        print("   Please run preprocessing/bulk_rnaseq/deseq2_pipeline.R first")
        print("   after downloading data from adknowledgeportal.synapse.org")
        return

    all_genes = bulk_df["gene"].unique()
    print(f"\nGenerating JSON files for {len(all_genes):,} genes...")

    success = 0
    for i, gene in enumerate(all_genes):
        if i % 1000 == 0:
            print(f"  Progress: {i:,} / {len(all_genes):,}")

        try:
            gene_json = build_gene_json(gene, bulk_df)
            out_path  = OUTPUT_DIR / f"{gene}.json"

            with open(out_path, "w") as f:
                json.dump(gene_json, f, separators=(",", ":"), allow_nan=False)
            success += 1
        except Exception as e:
            print(f"  ✗ Error for {gene}: {e}")

    print(f"\n✓ Complete: {success:,} JSON files written to {OUTPUT_DIR}/")
    print("\nNext step:")
    print("  Update index.html fetchGeneData() to load from ./data/genes/GENE.json")


if __name__ == "__main__":
    generate_all_jsons()
