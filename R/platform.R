resolve_platform <- function(df, sample_name) {
  n <- nrow(df)

  if (n == 937690) {
    list(
      manifest = epic_v2_manifest,
      interspecies_probes = interspecies_probes_v2
    )
  } else {
    list(
      manifest = epic_v1_manifest,
      interspecies_probes = interspecies_probes_v1
    )
  }
}
