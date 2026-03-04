# XenoMix
XenoMix is an R package designed to detect and quantify host (murine) DNA contamination in human patient-derived xenograft (PDX) samples profiled with Illumina Infinium Methylation arrays (EPIC and EPICv2).

## Overview 
A critical challenge in PDX research is the presence of murine-derived cells from the tumor microenvironment that are co-harvested with the human tumor fraction. XenoMix provides a robust *in silico* solution to estimate this contamination directly from raw methylation data without requiring additional laboratory work.

The algorithm identifies 15 inter-species informative probes from the Infinium Type I design that possess 100% sequence identity between human and mouse genomes but yield discordant single-base extension colors (Red vs. Green). By calculating the "wrong-color" signal fraction, the package provides a high-precision estimate of murine content.

## Background & Inspiration
The technical capacity for cross-species detection using Infinium Type I probes was first described by [Zhou et al. (2022)](https://doi.org/10.1016/j.xgen.2022.100144) for human DNA on mouse-specific arrays. XenoMix establishes the first formalized framework and background-correction logic to address the reciprocal—and clinically critical—case of murine contamination on human targeted arrays.

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
