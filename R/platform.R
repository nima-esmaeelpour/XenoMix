# ---- PLATFORM DETECTION ----

#' Resolve platform and return manifest and interspecies probes
#'
#' EPICv2 is identified by its unique probe count (937,690).
#' EPICv1 (~866k probes) and HM450 (~485k probes) share the same 15
#' interspecies probes and identical Type I color-channel assignments,
#' so both use the EPICv1 manifest as a look-up superset; the inner
#' join in `calculate_wrong_color_fraction()` naturally restricts to
#' probes present on the actual array.
#'
#' @param df Raw probe-level data frame
#' @param sample_name Character scalar identifying the sample
#' @return List with manifest and interspecies_probes
#' @noRd
resolve_platform <- function(df, sample_name) {
  n <- nrow(df)

  # EPICv2 has a distinct probe set and its own interspecies probes

  if (n == 937690) {
    return(list(
      manifest = epic_v2_manifest,
      interspecies_probes = interspecies_probes_v2
    ))
  }

  # EPICv1 and HM450 — warn if the probe count is outside the
  # expected range for either platform (~485k for HM450, ~866k for EPICv1)
  if (n < 400000 || n > 900000) {
    warning(sprintf(
      "Sample '%s': unexpected probe count (%d). Assuming EPICv1/HM450 probe set.",
      sample_name, n
    ), call. = FALSE)
  }

  list(
    manifest = epic_v1_manifest,
    interspecies_probes = interspecies_probes_v1
  )
}
