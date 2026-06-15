# ---- GLOBAL VARIABLES ----

# Declare global variables to prevent R CMD check warnings
# caused by non-standard evaluation (NSE) in dplyr.
utils::globalVariables(c(
  "Probe_ID",
  "Color_Channel",
  "MR",
  "UR",
  "MG",
  "UG",
  "wrong_color_signal",
  "total_signal",
  "wrong_color_fraction",
  "n_interspecies_probes",
  "median_signal",
  "se_signal",
  "mad_signal",
  "IlmnID"
))
