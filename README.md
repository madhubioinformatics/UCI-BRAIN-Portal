# 🧠 UCI BRAIN — Multi-omics Brain Disorder Portal

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Portal](https://img.shields.io/badge/Portal-Live%20Demo-blue)](https://madhusaddala.github.io/UCI-BRAIN-Portal)
[![GitHub Stars](https://img.shields.io/github/stars/madhusaddala/UCI-BRAIN-Portal?style=social)](https://github.com/madhusaddala/UCI-BRAIN-Portal)

**Developed by:** Madhu Sudhana Saddala and Vivek Swarup  
**Institution:** UCI MIND Institute · Department of Neurobiology & Behavior · University of California, Irvine  
**Contact:** msaddala@uci.edu  
**Portal URL:** https://madhubioinformatics.github.io/UCI-BRAIN-Portal/  

---

## Overview

**UCI BRAIN** (Brain Research Atlas and Integrative Network) is a comprehensive multi-omics interactive web portal for the neuroscience community. It integrates data across **13 large-scale cohorts**, **31 neurological and psychiatric disorders**, and **10 complementary analysis modules** — enabling researchers to query any human gene and instantly visualize its expression, regulation, and cell-type specificity across brain disorders.

UCI BRAIN is designed to be the brain-disorder substantially more comprehensive — covering single-cell, spatial, epigenomic, and cell-communication data that no existing brain portal currently provides.

---

## Key Features

| Module | Description | Data Source |
|---|---|---|
| 🧬 **Bulk RNA-seq** | DESeq2 differential expression · 8 figure tabs · 13,000+ samples | AMP-AD · TCGA · PsychENCODE · GTEx |
| 🔬 **Proteomics** | TMT-MS & Olink · Brain / CSF / Plasma · n= per group | CPTAC · AMP-AD · ADNI |
| 🧫 **scRNA-seq** | Seurat DimPlot/FeaturePlot UMAPs · EnhancedVolcano · 420k nuclei | Allen Brain Atlas · ROSMAP |
| 🗺️ **Spatial Tx** | 10x Visium · MERFISH · 5 brain regions · layer expression | UCI ADRC · Published atlases |
| 🏔️ **scATAC-seq** | Chromatin accessibility · TF motifs · Peak–gene links | UCI ADRC · GreenleafLab |
| 🔗 **Multi-omics** | WNN · MOFA+ · hdWGCNA · SCENIC+ GRN | RNA + ATAC joint |
| 🧲 **ChIP/Hi-C** | Histone marks · TAD boundaries · Enhancer–gene loops | ENCODE Brain |
| 💬 **CellChat** | Cell–cell communication · L-R bubble · Chord diagrams | snRNA-seq derived |
| 🤖 **AlphaGenome** | AI-predicted regulatory elements · Variant effect scores | DeepMind AlphaGenome |
| 🧠 **AI Interpret** | Claude AI result interpretation · Figure captions · Methods text | Anthropic API |

---

## Why UCI BRAIN is Unique

### Comparison to Existing Portals

| Feature | **UCI BRAIN** | UALCAN | AMP-AD Portal | GeneCards | Human Protein Atlas |
|---|---|---|---|---|---|
| Brain disorders (n) | **31** | ✗ cancer | AD only | ✗ | Partial |
| Bulk RNA-seq | ✓ 13 cohorts | ✓ TCGA only | ✓ AD only | ✗ | ✗ |
| scRNA-seq (UMAPs) | ✓ | ✗ | Partial | ✗ | ✓ Partial |
| Spatial Tx | ✓ | ✗ | ✗ | ✗ | ✓ Partial |
| scATAC-seq | ✓ | ✗ | ✗ | ✗ | ✗ |
| Multi-omics integration | ✓ | ✗ | ✗ | ✗ | ✗ |
| CellChat communication | ✓ | ✗ | ✗ | ✗ | ✗ |
| ChIP-seq / Hi-C | ✓ | ✗ | ✗ | ✗ | ✗ |
| AlphaGenome | ✓ | ✗ | ✗ | ✗ | ✗ |
| AI interpretation | ✓ | ✗ | ✗ | ✗ | ✗ |
| Individual figure download | ✓ | Partial | ✗ | ✗ | ✓ |

---

## Live Demo

🌐 **[https://madhusaddala.github.io/UCI-BRAIN-Portal](https://madhusaddala.github.io/UCI-BRAIN-Portal)**

> **⚠️ Data Status Notice:** The current live version uses **biologically realistic simulated data** parameterized from published effect sizes and summary statistics (sample sizes, fold changes, FDR thresholds) from the published literature. This allows full portal functionality to be demonstrated while real data integration is in progress.  
>
> Real data integration from AMP-AD, TCGA, GTEx, and Allen Brain Atlas is actively underway. See [Data Roadmap](#data-roadmap) below. **Do not use current numerical outputs for research conclusions.**

### Try These Example Queries
- Gene: `APP` · Disorder: Alzheimer's disease → all 10 modules
- Gene: `TREM2` · Disorder: Alzheimer's disease → CellChat, scRNA-seq
- Gene: `EGFR` · Disorder: Glioblastoma (GBM) → Bulk RNA-seq, Survival
- Gene: `SNCA` · Disorder: Parkinson's disease → Multi-omics, ChIP/Hi-C
- Gene: `MECP2` · Disorder: Rett syndrome → Spatial Tx, scATAC-seq

---

## Quick Start

UCI BRAIN is a **single self-contained HTML file** — no installation, no dependencies, no server required.

```bash
# Clone the repository
git clone https://github.com/madhusaddala/UCI-BRAIN-Portal.git
cd UCI-BRAIN-Portal

# Open directly in browser (macOS)
open index.html

# Open directly in browser (Linux)
xdg-open index.html

# Open directly in browser (Windows)
start index.html
```

Or simply download `index.html` and open it in Chrome, Firefox, Safari, or Edge.

---

## Repository Structure

```
UCI-BRAIN-Portal/
│
├── index.html                   # Complete portal (single self-contained file, ~880 KB)
├── README.md                    # This file
├── LICENSE                      # MIT License
├── CITATION.cff                 # Machine-readable citation
├── .nojekyll                    # GitHub Pages: skip Jekyll build
│
├── preprocessing/               # Data processing pipelines (R + Python)
│   ├── README.md
│   ├── bulk_rnaseq/
│   │   ├── deseq2_pipeline.R    # DESeq2 pipeline for AMP-AD data
│   │   └── gtex_normalization.R
│   ├── scrna/
│   │   ├── seurat_pipeline.R    # Seurat/Scanpy scRNA-seq pipeline
│   │   └── pseudobulk_de.R
│   ├── proteomics/
│   │   └── limma_pipeline.R
│   └── data_integration/
│       └── json_generator.py    # Convert processed data to portal JSON format
│
├── data/
│   ├── README.md                # Data sources, access instructions, Synapse IDs
│   └── schema/
│       └── gene_data_schema.json # JSON schema for real data integration
│
└── docs/
    ├── tutorial.md              # Detailed user tutorial
    ├── data_access.md           # How to access real data sources
    ├── api_integration.md       # How to connect real data to portal
    └── screenshots/
        ├── bulk_rnaseq_APP.png
        ├── umap_celltype.png
        ├── enhancedvolcano.png
        ├── cellchat_chord.png
        └── multiomics_wnn.png
```

---

## Data Roadmap

Data access requests have been submitted. Real data will be integrated module by module.

| Module | Status | Data Source | Synapse ID | Est. Integration |
|---|---|---|---|---|
| Bulk RNA-seq (AD) | 🟡 DUC submitted | AMP-AD ROSMAP | syn4164376 | Q2 2026 |
| Bulk RNA-seq (GBM/LGG) | 🟡 Downloading | TCGA GDC Portal | — | Q2 2026 |
| Bulk RNA-seq (Normal) | 🟡 Downloading | GTEx Brain v10 | — | Q2 2026 |
| Bulk RNA-seq (SCZ/BPD) | 🔴 Pending | PsychENCODE | — | Q3 2026 |
| Proteomics | 🟡 DUC submitted | CPTAC + AMP-AD | syn21261728 | Q2 2026 |
| scRNA-seq | 🟡 DUC submitted | Allen Brain + SEA-AD | syn52293417 | Q3 2026 |
| Spatial Tx | 🔴 In preparation | UCI ADRC Visium | UCI internal | Q3 2026 |
| scATAC-seq | 🔴 Pending | ROSMAP ATAC | Synapse | Q3 2026 |
| Multi-omics | 🔴 Pending | WNN joint RNA+ATAC | UCI internal | Q4 2026 |
| ChIP/Hi-C | 🔴 Pending | ENCODE Brain | ENCODE Portal | Q4 2026 |
| CellChat | 🔴 Pending | snRNA-seq derived | — | Q3 2026 |

**Status:** 🟢 Complete · 🟡 In progress · 🔴 Planned

### Data Sources

| Dataset | Portal | n Samples | Modality |
|---|---|---|---|
| AMP-AD (ROSMAP + Mayo + MSBB) | adknowledgeportal.synapse.org | 2,114 | Bulk RNA-seq |
| TCGA (GBM + LGG + MED) | portal.gdc.cancer.gov | 1,103 | Bulk RNA-seq |
| PsychENCODE | psychencode.org | 1,866 | Bulk RNA-seq |
| GTEx Brain (16 regions) | gtexportal.org | 980 | Bulk RNA-seq (normal) |
| ADNI | adni.loni.usc.edu | 462 | RNA-seq + biomarkers |
| PPMI | ppmi-info.org | 312 | RNA-seq |
| TargetALS | targetals.org | 389 | RNA-seq |
| CBTN (pediatric brain) | cbtn.org | 846 | RNA-seq |
| Allen Brain Cell Atlas | portal.brain-map.org | 3.3M nuclei | snRNA-seq |
| CPTAC | cptac-data-portal.georgetown.edu | 218 | TMT Proteomics |
| ENCODE Brain | encodeproject.org | — | ChIP-seq / ATAC-seq |
| UCI ADRC (Swarup Lab) | UCI internal | 243 | RNA + Spatial + ATAC |

---

## Technical Architecture

UCI BRAIN is built as a **zero-dependency single-file web application**:

- **Frontend:** Vanilla JavaScript + HTML5 Canvas API + SVG
- **Visualization:** Custom Canvas 2D renderers (UMAP, EnhancedVolcano, box plots, chord diagrams) + Chart.js 4.4.1 (inlined)
- **PDF export:** jsPDF 2.5.1 (inlined)
- **AI:** Claude Sonnet API (Anthropic) for result interpretation
- **Data:** Pre-computed gene-level summary statistics served as JSON
- **No server required:** Runs entirely in the browser

---

## Installation for Developers

```bash
git clone https://github.com/madhusaddala/UCI-BRAIN-Portal.git
cd UCI-BRAIN-Portal

# To connect real data (after processing):
# 1. Run preprocessing pipelines in preprocessing/
# 2. Generate gene JSON files with data_integration/json_generator.py
# 3. Place JSON files in data/genes/ directory
# 4. Update the portal's fetchGeneData() function to load from ./data/genes/
```

---

## Citation

If you use UCI BRAIN in your research, please cite:

```bibtex
@article{saddala2026ucibrain,
  title     = {Multi-omics characterization of the human brain
               transcriptome in neurological disorders},
  author    = {Saddala, Madhu Sudhana and Swarup, Vivek},
  journal   = {Nature Genetics},
  year      = {2026},
  publisher = {Nature Publishing Group},
  url       = {https://madhubioinformatics.github.io/UCI-BRAIN-Portal/},
  note      = {UCI MIND Institute, University of California Irvine}
}
```

---

## License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

Free to use, modify, and distribute with attribution.

---

## Acknowledgments

**Data sources:** AMP-AD Knowledge Portal (Sage Bionetworks), TCGA (NCI GDC), GTEx Consortium, Allen Brain Institute, PsychENCODE Consortium, CPTAC (NCI), ADNI, PPMI, TargetALS Foundation, CBTN, ENCODE Project.

**Methods:** DESeq2, Seurat, Scanpy, EnhancedVolcano (Blighe et al.), CellChat (Jin et al.), SCENIC+, MOFA+, hdWGCNA, AlphaGenome (DeepMind).

**AI:** Claude API (Anthropic) for result interpretation.

**Funding:** NIA, NINDS, UCI MIND Institute, University of California Irvine.
