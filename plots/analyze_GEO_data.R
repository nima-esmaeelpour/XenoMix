# ---- SETUP ----
OUT_PATH <- "out"
dir.create(OUT_PATH, recursive = TRUE, showWarnings = FALSE)

# ---- PROCESS DATASETS ----
all_dirs <- list.dirs("idat", full.names = TRUE, recursive = FALSE)
idat_dirs <- all_dirs[grepl("idat_", basename(all_dirs))]

for (idat_dir in idat_dirs) {
  geo_id <- sub(".*idat_", "", idat_dir)
  output_file <- file.path(OUT_PATH, sprintf("xeno_report_%s.csv", geo_id))

  if (file.exists(output_file)) {
    message(sprintf("===> Skipping %s (Output already exists)", geo_id))
    next
  }

  message(sprintf("\n--- ANALYZING DATASET: %s ---", geo_id))

  sample_annotation <- read.csv(file.path(idat_dir, "sample_annotation.csv"))
  xeno_results <- run_xeno(idat_dir, n_cores = 8)

  xeno_results <- xeno_results |>
    dplyr::mutate(geo_accession = sub("_.*", "", sample)) |>
    dplyr::select(-sample)

  final_report <- sample_annotation |>
    dplyr::left_join(xeno_results, by = "geo_accession")

  write.csv(final_report, output_file, row.names = FALSE)
  message(sprintf("===> Success: Saved to %s", output_file))
}
