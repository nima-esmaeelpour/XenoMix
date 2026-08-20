# ---- HELPER FUNCTIONS ----

standard_error <- function(x, na.rm = FALSE) {
  if (na.rm) {
    x <- x[!is.na(x)]
  }
  stats::sd(x) / sqrt(length(x))
}

filter_type_I_probes <- function(df, manifest) {
  dplyr::filter(df, Probe_ID %in% manifest$IlmnID)
}

calculate_wrong_color_fraction <- function(df, manifest) {
  channel_map <- dplyr::select(manifest, IlmnID, Color_Channel)

  df |>
    dplyr::left_join(channel_map, by = c("Probe_ID" = "IlmnID")) |>
    dplyr::mutate(
      total_signal = MR + UR + MG + UG,
      wrong_color_signal = dplyr::if_else(
        Color_Channel == "Grn",
        MR + UR,
        MG + UG
      ),
      wrong_color_fraction = wrong_color_signal / total_signal
    )
}

# ---- CORE LOGIC ----

MIN_TOTAL_SIGNAL <- 1000
LOW_SIGNAL_CUTOFF <- 0.4

#' Compute xenograft (interspecies) contamination metrics for one sample
#'
#' @param df          Raw probe-level data frame (columns: Probe_ID, MR, UR, MG, UG)
#' @param sample_name Character scalar identifying the sample
#' @return Single-row data.frame with contamination metrics
#' @noRd
add_xeno <- function(df, sample_name) {
  platform <- resolve_platform(df, sample_name)
  manifest <- platform$manifest
  interspecies_probes <- platform$interspecies_probes

  df <- df |>
    filter_type_I_probes(manifest) |>
    calculate_wrong_color_fraction(manifest) |>
    dplyr::filter(MR + UR + MG + UG > MIN_TOTAL_SIGNAL)

  background <- stats::median(df$wrong_color_fraction, na.rm = TRUE)
  background_se <- standard_error(df$wrong_color_fraction, na.rm = TRUE)
  background_mad <- stats::mad(df$wrong_color_fraction, na.rm = TRUE)

  xeno_signal_stats <- df |>
    dplyr::filter(Probe_ID %in% interspecies_probes) |>
    dplyr::summarize(
      n_interspecies_probes = dplyr::n(),
      median_signal = stats::median(wrong_color_fraction, na.rm = TRUE),
      se_signal = standard_error(wrong_color_fraction, na.rm = TRUE),
      mad_signal = stats::mad(wrong_color_fraction, na.rm = TRUE)
    )

  mouse_fraction <- compute_mouse_fraction(
    xeno_signal_stats$median_signal,
    background
  )

  data.frame(
    sample = sample_name,
    probes_used = xeno_signal_stats$n_interspecies_probes,
    mouse_signal = xeno_signal_stats$median_signal,
    sem_mouse_signal = xeno_signal_stats$se_signal,
    mad_mouse_signal = xeno_signal_stats$mad_signal,
    background_signal = background,
    sem_background = background_se,
    mad_background = background_mad,
    mouse_fraction = mouse_fraction,
    stringsAsFactors = FALSE
  )
}

#' Adjust raw mouse signal by subtracting array-wide background
#'
#' Even in pure-human samples, Type I probes show a small baseline
#' wrong-color fraction due to optical crosstalk and non-specific
#' hybridisation.  This background is estimated as the median
#' wrong-color fraction across all Type I probes and subtracted from
#' the interspecies-probe signal.
#'
#' Background subtraction is applied only when the raw signal is below
#' `LOW_SIGNAL_CUTOFF` (0.4).  Above that threshold the sample is
#' heavily contaminated and the interspecies probes themselves
#' dominate the array-wide median, so subtracting it would
#' artificially deflate the estimate.
#'
#' Returns 1 (worst case) when no interspecies probes are available
#' (i.e. `mouse_med` is `NA`), and clamps the result to `[0, 1]`.
#'
#' @param mouse_med Numeric. Median wrong-color fraction of interspecies probes.
#' @param background Numeric. Median wrong-color fraction across all Type I probes.
#' @return Numeric scalar — estimated mouse DNA fraction.
#' @noRd
compute_mouse_fraction <- function(mouse_med, background) {
  dplyr::case_when(
    is.na(mouse_med) ~ 1,
    mouse_med < LOW_SIGNAL_CUTOFF ~ pmax(0, mouse_med - background),
    TRUE ~ mouse_med
  )
}
