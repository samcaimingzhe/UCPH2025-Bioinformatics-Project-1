# Dorado RNA Modification Analysis Pipeline (Mingzhe Cai)

This repository contains a complete bioinformatics pipeline for processing, analyzing, and visualizing RNA modification data (specifically m6A) from Oxford Nanopore direct RNA sequencing. 

The pipeline is split into two main parts:
1. **Upstream Processing (`drd.sh`)**: Basecalling POD5 files using Dorado, sorting/indexing with Samtools, and generating modification bed files using Modkit.
2. **Downstream Analysis (`for_users.R`)**: Cleaning the BED data, merging replicates (Col-0 and 9BE mutants), filtering false positives against a MOCK control, and generating publication-ready visualizations in R.

---

## 🛠️ Prerequisites

### Upstream Software (Linux)
To run the bash script (`drd.sh`), your environment must have:
* **[Dorado](https://github.com/nanoporetech/dorado)** (Requires CUDA-enabled GPUs; script defaults to `cuda:0,1,2`)
* **[Samtools](http://www.htslib.org/)**
* **[Modkit](https://github.com/nanoporetech/modkit)**

### Downstream Software (Local)
To run the R scripts, ensure you have **R (>= 4.0.0)** installed along with the following packages:
```R
install.packages(c("tidyverse", "ggplot2", "patchwork", "ggrepel", "writexl"))
```

---

## 📂 Directory Structure

For the R scripts to work correctly, your local project directory should look like this:

```text
project_root/
├── drd.sh                  # Upstream bash pipeline
├── for_users.R             # Entry point script for users (can also be get_plots.R)
├── dorado_functions.R      # Core data processing & plotting functions
├── dorado_plotting.R       # Main script that combines data and generates plots
├── README.md               # This file
└── Mar_drd/                # Directory containing the modkit output BED files
    ├── pileup_total_*.bed  # BED files for total extraction
    └── pileup_virion_*.bed # BED files for VP extraction
```
*(Note: If your `.bed` files are in a zip archive like `BED_FILES.zip`, you must unzip them into the `Mar_drd/` directory before running the R scripts).*

---

## 🚀 Usage Guide

### Step 1: Upstream Processing (Basecalling & Pileup)
Run the `drd.sh` script on your GPU-enabled server. This script reads text files (`pod5_total.txt`, `pod5_virion.txt`) containing paths to your POD5 directories.

```bash
bash drd.sh
```
**What it does:**
1. Runs `dorado basecaller` with the `sup` model and `--modified-bases inosine_m6A_2OmeA`.
2. Uses `samtools` to sort and index the resulting `.bam` files.
3. Runs `modkit pileup` to extract m6A modification data into 18-column `.bed` files.

### Step 2: Downstream Analysis & Visualization
Transfer the generated `.bed` files to your local machine and place them in the `Mar_drd/` folder. 

Open `for_users.R` (or `get_plots.R`) in RStudio and configure the three core parameters:
* `set_min` (Default `5`): Minimum modification fraction (%) to be included in the scatter plots.
* `set_diff` (Default `3`): The threshold used to filter false positives (Sample Mod % must be greater than MOCK Mod % + `set_diff`).
* `min_cov` (Default `100`): Minimum sequencing depth required for a valid site.

**Run the pipeline:**
Execute the `for_users.R` script. It will automatically source `dorado_plotting.R` (which in turn sources `dorado_functions.R`) and generate all data frames and plots in your R environment.

---

## 📊 Outputs

Once the R pipeline finishes executing, you can call the following variables in your R console to view the generated plots:

| Plot Variable | Description |
| :--- | :--- |
| `reads_barplot` | Bar plot showing the total number of valid reads mapped to RNA1, RNA2, and RNA3 across all samples. |
| `total_scatter_plot` | 4-panel scatter plot comparing modification fractions between Total RNA samples (Col-0/9BE vs. MOCK) on RNA2 and RNA3. |
| `vp_scatter_plot` | 4-panel scatter plot comparing modification fractions between Virion (VP) RNA samples (Col-0/9BE vs. MOCK) on RNA2 and RNA3. |
| `site_reads_plot` | Bar plots visualizing the raw read depth coverage for specific candidate sites (e.g., RNA2:2533, RNA3:1975). |
| `site_frac_plot` | Bar plots visualizing the exact modification fractions for specific candidate sites across replicates. |
| `class_plot` | A diagnostic scatter plot of *Weighted Variance/Mean vs. Difference Value* to help identify and classify high-confidence modification sites. |

### Exported Data
* **`6_sites_info.xlsx`**: An Excel file exported to your root directory containing the raw extracted data (fraction modified, coverage, etc.) for the highlighted candidate sites across all extraction methods and replicates.
