#' Run Xeno Mouse Fraction Analysis
#'
#' @description
#' Processes IDAT files from a specified directory to calculate xenograft
#' (mouse) fraction. Automatically detects EPIC v1 vs v2 arrays.
#'
#' @param idat_path Character. Path to the directory containing .idat files.
#' @param n_cores Integer. Number of cores for parallel processing (default is 1).
#'
#' @return A data frame containing sample names and calculated mouse fractions.
#' @export
run_xeno <- function(idat_path, n_cores = 1) {
  # Check for presence of raw data
  idat_files <- list.files(idat_path, "\\.idat$")
  if (length(idat_files) == 0) {
    stop("No .idat files found in: ", idat_path, call. = FALSE)
  }

  # Read IDATs into Signal Data Frames (SigDFs)
  message(sprintf("[STARTED] Reading %s directory...", idat_path))
  sdfs <- sesame::openSesame(
    idat_path,
    func = NULL, # Returns raw SigDFs without preprocessing
    BPPARAM = BiocParallel::MulticoreParam(n_cores)
  )
  message(sprintf("[FINISHED] Reading %s directory...", idat_path))

  # Force result into a list since sesame returns a single object if N=1, but a list if N > 1
  if (!is.list(sdfs) || methods::is(sdfs, "SigDF")) {
    sdfs <- list(sample = sdfs)
  }

  # Calculate fractions per sample
  results <- vector("list", length(sdfs))
  i <- 1
  for (sample_name in names(sdfs)) {
    results[[i]] <- add_xeno(sdfs[[sample_name]], sample_name)
    i <- i + 1
  }

  # Combine list of data frames into a single output table
  dplyr::bind_rows(results)
}
