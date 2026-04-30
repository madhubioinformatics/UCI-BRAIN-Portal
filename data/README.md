# UCI BRAIN Portal — Data Sources & Access

This directory contains data schemas and will hold processed gene-level
summary statistics once real data is downloaded and processed.

## Current Status

The portal currently runs with biologically realistic simulated data.
Real data integration is in progress — see the table below.

## Data Sources & Synapse IDs

### Bulk RNA-seq

| Dataset | Synapse ID | Access | Status |
|---|---|---|---|
| AMP-AD Harmonized (ROSMAP+Mayo+MSBB) | syn21241740 | DUC required | 🟡 DUC submitted |
| ROSMAP bulk RNA-seq | syn4164376 | DUC required | 🟡 DUC submitted |
| MSBB bulk RNA-seq | syn20801188 | DUC required | 🟡 DUC submitted |
| TCGA-GBM | GDC Portal | Open | 🟡 Downloading |
| TCGA-LGG | GDC Portal | Open | 🟡 Downloading |
| GTEx Brain v10 | gtexportal.org | Open | 🟡 Downloading |
| PsychENCODE | psychencode.org | Free registration | 🔴 Planned |

### Proteomics

| Dataset | Synapse ID | Access | Status |
|---|---|---|---|
| ROSMAP proteomics | syn21261728 | DUC required | 🟡 DUC submitted |
| MSBB proteomics | syn21347564 | DUC required | 🟡 DUC submitted |

### Single-cell RNA-seq

| Dataset | Synapse ID / URL | Access | Status |
|---|---|---|---|
| ROSMAP snRNA-seq | syn52293417 | DUC required | 🟡 DUC submitted |
| Allen Brain Cell Atlas | portal.brain-map.org | Open | 🔴 Planned |
| SEA-AD | portal.brain-map.org | Open | 🔴 Planned |

## How to Access AMP-AD Data

1. Create account: https://www.synapse.org
2. Request access: https://adknowledgeportal.synapse.org/DataAccess/Instructions
3. Complete Data Use Certificate (DUC): https://www.synapse.org/#!Synapse:syn25441378
4. After approval (~1-2 weeks), download with:

```bash
pip install synapseclient
synapse login
synapse get syn21241740 --downloadLocation ./raw/ampad/
synapse get syn4164376  --downloadLocation ./raw/rosmap/
synapse get syn21261728 --downloadLocation ./raw/rosmap_prot/
```

## How to Access TCGA Data (No approval needed)

```bash
# Install GDC client
# Download from: https://gdc.cancer.gov/access-data/gdc-data-transfer-tool

# Download GBM RNA-seq
gdc-client download -m manifest_TCGA-GBM.txt -d ./raw/tcga_gbm/

# Download LGG RNA-seq
gdc-client download -m manifest_TCGA-LGG.txt -d ./raw/tcga_lgg/
```

## How to Access GTEx Data (No approval needed)

```bash
# Download from gtexportal.org
wget https://storage.googleapis.com/adult-gtex/bulk-gex/v10/rna-seq/\
GTEx_Analysis_v10_RNASeQCv2.4.2_gene_tpm.gct.gz -P ./raw/gtex/

wget https://storage.googleapis.com/adult-gtex/annotations/v10/\
GTEx_Analysis_v10_Annotations_SampleAttributesDS.txt -P ./raw/gtex/
```

## Expected Data Directory Structure (after download)

```
data/
├── README.md            (this file)
├── schema/
│   └── gene_data_schema.json
├── raw/                 (downloaded data — not committed to git, see .gitignore)
│   ├── rosmap/
│   ├── tcga_gbm/
│   ├── tcga_lgg/
│   └── gtex/
├── processed/           (DESeq2/limma outputs — not committed to git)
│   └── bulk_rnaseq/
└── genes/               (per-gene JSON files for portal — not committed to git)
    ├── APP.json
    ├── TREM2.json
    └── ...
```

> **Note:** Raw data, processed results, and gene JSON files are NOT committed
> to this repository due to size and data sharing restrictions.
> They are generated locally by running the preprocessing pipelines.
