# tests/test_installation.R
library(XenoMix)

test_dir <- "test_data_mouse"
dir.create(test_dir, showWarnings = FALSE)

# Temporary GitHub Link
base_url <- "https://raw.githubusercontent.com/nima-esmaeelpour/temp_idat_file/main/"
files <- c(
  "209344100104_R08C01_Grn.idat",
  "209344100104_R08C01_Red.idat"
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

# A 100% mouse sample should yield a fraction very close to 1.0
if (nrow(results) > 0 && results$mouse_fraction[1] > 0.95) {
  message(
    "\nTEST PASSED: Detected high mouse content (>95%) in the test sample."
  )
} else {
  stop(
    "\nTEST FAILED: The detected mouse fraction was lower than expected or the run failed."
  )
}
