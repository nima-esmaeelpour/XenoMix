add_xeno <- function(df, sample_name) {
  platform <- resolve_platform(df, sample_name)
  manifest <- platform$manifest
  interspecies_probes <- platform$interspecies_probes

  df <- filter_type_I_probes(df, manifest)
  df <- calculate_wrong_color_fraction(df, manifest)
  df <- df %>% dplyr::filter(rowSums(.[2:5]) > 1000)
  bg <- stats::median(df$wrong_color_fraction, na.rm = TRUE)

  mouse <- df |>
    dplyr::filter(Probe_ID %in% interspecies_probes) |>
    dplyr::summarize(med = stats::median(wrong_color_fraction)) |>
    dplyr::pull(med)

  frac <- ifelse(is.na(mouse), 1,
    ifelse(mouse < 0.33, pmax(0, mouse - bg), mouse)
  )

  data.frame(
    sample = sample_name,
    background_signal = bg,
    mouse_signal = mouse,
    mouse_fraction = frac,
    stringsAsFactors = FALSE
  )
}

filter_type_I_probes <- function(df, manifest) {
  df <- df |> dplyr::filter(Probe_ID %in% manifest$IlmnID)
}

calculate_wrong_color_fraction <- function(df, manifest) {
  df |>
    dplyr::left_join(
      manifest |> dplyr::select(IlmnID, Color_Channel),
      by = c("Probe_ID" = "IlmnID")
    ) |>
    dplyr::mutate(
      wrong_color_fraction =
        ifelse(Color_Channel == "Grn",
          (MR + UR) / (MR + UR + MG + UG),
          (MG + UG) / (MR + UR + MG + UG)
        )
    )
}
