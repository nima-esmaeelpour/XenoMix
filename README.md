# XenoMix
XenoMix is an R package designed to detect and quantify host (murine) DNA contamination in human patient-derived xenograft (PDX) samples profiled with Illumina Infinium Methylation arrays (EPIC and EPICv2).

## Overview 
A critical challenge in PDX research is the presence of murine-derived cells from the tumor microenvironment that are co-harvested with the human tumor fraction. XenoMix provides a robust *in silico* solution to estimate this contamination directly from raw methylation data without requiring additional laboratory work.

The algorithm identifies 15 inter-species informative probes from the Infinium Type I design that possess 100% sequence identity between human and mouse genomes but yield discordant single-base extension colors (Red vs. Green). By calculating the "wrong-color" signal fraction, the package provides a high-precision estimate of murine content.

## Background & Inspiration
The technical capacity for cross-species detection using Infinium Type I probes was first described by [Zhou et al. (2022)](https://doi.org/10.1016/j.xgen.2022.100144) for human DNA on mouse-specific arrays. XenoMix establishes the first formalized framework and background-correction logic to address the reciprocal case of murine contamination on human targeted arrays.

## Key Features
- Accurate Quantification: Achieved a validation $R^2 = 0.991$ on ground-truth human-mouse DNA mixtures.
- Retrospective Analysis: Quantify contamination in existing datasets where physical samples are no longer accessible.
- Validated on Real-World Data: Performance confirmed across 227 publicly available samples from the Gene Expression Omnibus (GEO).

# Installation

## Requirements

XenoMix requires the [sesame](https://www.bioconductor.org/packages/release/bioc/html/sesame.html) R package, which can be installed from Bioconductor:
```R
# install.packages("BiocManager)
BiocManager::install("sesame")
```

Sesame requires a one-time download of array manifests to your local machine:
```R
library(sesameData)
sesameDataCache()
```

## Install XenoMix

You can install the development version of XenoMix from GitHub with:
```R
# install.packages("devtools")
devtools::install_gitlab("b370/scepigen/XenoMix", host="git.dkfz.de")
```

# Quick Start
```R
library(XenoMix)
# Load your raw IDAT files
idat_path <- "path/to/idat/files"

# Run the contamination estimate
xeno_report <- run_xeno(idat_path)

# View the results (predicted mouse fraction)
print(xeno_report)
````

# Verification with Test Dataset

To verify that XenoMix is installed correctly and the `sesame` manifests are working, you can run the provided test script. This script downloads a 100% Mouse IDAT pair (approx. 30MB) from our secure server and processes it.

### Instructions
Run the following in your R console:
```R
source("tests/test_installation.R")
```

# Reproduce Publication Figures

To ensure transparency and reproducibility, we provide the complete pipeline used to generate the figures in our paper. This process involves downloading ~20GB of raw data from the Gene Expression Omnibus (GEO), processing it through `XenoMix`, and generating the final PDF plots.

### Additional Dependencies
The reproduction scripts require a few extra packages for data handling and visualization:

```R
BiocManager::install(c("sesameData", "GEOquery", "Biobase"))
install.packages(c("dplyr", "ggplot2", "stringr", "future", "future.apply", "R.utils", "purrr"))
````

### Run the Full Pipeline
```R
# Note: This will download several GBs of data and may take significant time depending on your connection and CPU.
source("plots/plot_GEO_data.R")
```

All intermediate data frames and final PDF figures will be saved automatically to a newly created out/ directory.