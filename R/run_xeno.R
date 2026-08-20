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
  
  # ---- INPUT VALIDATION ----
  
  if (!is.character(idat_path) || length(idat_path) != 1) {
    stop("`idat_path` must be a single character string.", call. = FALSE)
  }
  if (!dir.exists(idat_path)) {
    stop("Directory does not exist: ", idat_path, call. = FALSE)
  }
  if (!is.numeric(n_cores) || length(n_cores) != 1 || n_cores < 1) {
    stop("`n_cores` must be a positive integer.", call. = FALSE)
  }
  
  # ---- LOAD DATA ----
  
  idat_files <- list.files(idat_path, "\\.idat$")
  if (length(idat_files) == 0) {
    stop("No .idat files found in: ", idat_path, call. = FALSE)
  }

  bp <- BiocParallel::SnowParam(n_cores)

  message(sprintf("[STARTED] Reading %s directory...", idat_path))
  sdfs <- sesame::openSesame(
    idat_path,
    func = NULL,
    BPPARAM = bp
  )
  message(sprintf("[FINISHED] Reading %s directory...", idat_path))

  # ---- PROCESS SAMPLES ----
  
  if (!is.list(sdfs) || methods::is(sdfs, "SigDF")) {
    sdfs <- list(sample = sdfs)
  }

  results <- BiocParallel::bplapply(
    names(sdfs),
    \(nm) add_xeno(sdfs[[nm]], nm),
    BPPARAM = bp
  )

  dplyr::bind_rows(results)
}
