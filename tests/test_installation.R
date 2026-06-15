# tests/test_installation.R
library(XenoMix)

test_dir <- "test_data_mouse"
dir.create(test_dir, showWarnings = FALSE)

# Temporary GitHub Link
base_url <- "https://ftp.ebi.ac.uk/pub/databases/biostudies/E-MTAB-/743/E-MTAB-16743/Files/"
files <- c(
  "209344100104_R04C01_Grn.idat",
  "209344100104_R04C01_Red.idat"
)

# Download the files
message("Downloading test .idat files from GitHub...")
for (f in files) {
  dest <- file.path(test_dir, f)
  if (!file.exists(dest)) {
    download.file(paste0(base_url, f), dest, mode = "wb")
  }
}

# Run XenoMix
message("Running XenoMix on test data...")
results <- run_xeno(test_dir, n_cores = 1)
print(results)

# A 45% mouse sample should yield a fraction between 40 and 50%
if (
  nrow(results) > 0 &&
    results$mouse_fraction[1] > 0.4 &&
    results$mouse_fraction[1] < 0.5
) {
  message(
    "\nTEST PASSED: Detected mouse content is approximately ",
    sprintf("%.2f%%", results$mouse_fraction[1] * 100),
    " in the test sample. Ground Truth: 45% mouse."
  )
} else {
  stop(
    "\nTEST FAILED: The detected mouse fraction was different from what was expected or the run failed."
  )
}
