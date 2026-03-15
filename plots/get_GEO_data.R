#' Download and Unpack GEO IDAT files
#'
#' @param geo Character. The GSE accession number.
#' @param platform_num Integer. The index of the platform in the GSE object.
get_geo_data <- function(geo, platform_num) {
  geo_dir <- file.path("idat", paste0("idat_", geo, "_", platform_num))

  if (!dir.exists(geo_dir)) {
    message(sprintf("===> Fetching metadata for %s...", geo))

    # Create directory
    dir.create(geo_dir, recursive = TRUE, showWarnings = FALSE)

    # Download GSE metadata
    gse <- GEOquery::getGEO(geo, destdir = geo_dir)
    gse_obj <- gse[[platform_num]]
    sample_annotation <- Biobase::pData(gse_obj)

    # Save metadata for later curation
    write.csv(sample_annotation, file.path(geo_dir, "sample_annotation.csv"))

    # Download supplemental .idat files for each GSM
    gsms <- sample_annotation$geo_accession
    message(sprintf("===> Downloading %d samples for %s...", length(gsms), geo))

    for (gsm in gsms) {
      GEOquery::getGEOSuppFiles(gsm, makeDirectory = FALSE, baseDir = geo_dir)
    }

    # Unzip .gz files
    gz_files <- list.files(geo_dir, pattern = "\\.gz$", full.names = TRUE)
    if (length(gz_files) > 0) {
      message("===> Uncompressing IDAT files...")
      lapply(gz_files, function(f) {
        R.utils::gunzip(f, remove = TRUE, overwrite = TRUE)
      })
    }
    message(sprintf("===> Finished %s", geo))
  } else {
    message(sprintf("===> %s already exists. Skipping download.", geo_dir))
  }
}

# ---- Execution Block ----
# Set up parallel workers
future::plan(future::multisession, workers = 4)

# Define the datasets to download
geo_tasks <- list(
  list("GSE228820", 1),
  list("GSE228820", 2),
  list("GSE240469", 1),
  list("GSE273176", 1),
  list("GSE308997", 1),
  list("GSE289988", 1),
  list("GSE165050", 1),
  list("GSE271621", 1),
  list("GSE271621", 2),
  list("GSE240412", 1),
  list("GSE227695", 1)
)

message("Starting bulk GEO download...")
future.apply::future_lapply(geo_tasks, function(task) {
  get_geo_data(task[[1]], task[[2]])
})

# Return to sequential processing when done
future::plan(future::sequential)
