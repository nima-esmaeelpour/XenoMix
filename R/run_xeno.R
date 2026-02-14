#' Run Xeno Mouse Fraction Analysis
#' @export
run_xeno <- function(idat_path, n_cores = 1) {
  # Check if .idat files exist
  idat_files <- list.files(idat_path, "\\.idat$")
  if (length(idat_files) == 0) {
    stop("No .idat files found in: ", idat_path, call. = FALSE)
  }

  # Read .idat files
  message(sprintf("[STARTED] Reading %s directory...", idat_path))
  sdfs <- sesame::openSesame(
    idat_path,
    func = NULL,
    BPPARAM = BiocParallel::MulticoreParam(n_cores)
  )
  message(sprintf("[FINISHED] Reading %s directory...", idat_path))

  # Convert to list if only one sample (i.e. two .idat files)
  if (!is.list(sdfs) || methods::is(sdfs, "SigDF")) {
    sdfs <- list(sample = sdfs)
  }

  # Add xeno content
  results <- vector("list", length(sdfs))
  i <- 1
  for (sample_name in names(sdfs)) {
    results[[i]] <- add_xeno(sdfs[[sample_name]], sample_name)
    i <- i + 1
  }

  # Return final df
  dplyr::bind_rows(results)
}
