# ---- SETUP ----
OUT_PATH <- "out"

# ---- HELPER FUNCTION ----
process_gse_report <- function(
  gse_id,
  platform_idx,
  platform_name,
  s_type,
  t_type,
  c_line
) {
  file_name <- sprintf("xeno_report_%s_%d.csv", gse_id, platform_idx)
  file_path <- file.path(OUT_PATH, file_name)

  # Skip if file doesn't exist
  if (!file.exists(file_path)) {
    warning("File not found: ", file_path)
    return(NULL)
  }

  read.csv(file_path) |>
    dplyr::mutate(
      gse = gse_id,
      platform = platform_name,
      sample_type = s_type,
      tumor_type = t_type,
      cell_line = c_line
    ) |>
    dplyr::select(
      geo_accession,
      gse,
      platform,
      sample_type,
      tumor_type,
      cell_line,
      probes_used,
      mouse_signal,
      sem_mouse_signal,
      mad_mouse_signal,
      background_signal,
      sem_background,
      mad_background,
      mouse_fraction
    )
}

# --- Data Curation ---
results_list <- list(
  # GSE228820
  process_gse_report(
    "GSE228820",
    1,
    "EPICv1",
    "human",
    c(
      "LCL",
      "CML",
      "Prostate",
      rep("LCL", 6),
      rep("control", 7),
      rep("CRC", 2)
    ),
    read.csv(file.path(OUT_PATH, "xeno_report_GSE228820_1.csv"))$cell.line.ch1
  ),

  process_gse_report(
    "GSE228820",
    2,
    "EPICv2",
    c(rep("human", 8), rep("mouse", 2), rep("human", 28)),
    c(
      rep("LCL", 2),
      rep("CML", 2),
      rep("Prostate", 2),
      rep("CRC", 2),
      rep("control", 2),
      rep("CRC", 6),
      rep("LCL", 5),
      rep("CML", 4),
      rep("control", 7),
      rep("CRC", 6)
    ),
    read.csv(file.path(OUT_PATH, "xeno_report_GSE228820_2.csv"))$cell.line.ch1
  ),

  # GSE240469
  process_gse_report(
    "GSE240469",
    1,
    "EPICv2",
    c(rep("human", 32), rep("PDX", 8)),
    c(
      rep("control", 3),
      rep("Prostate", 13),
      rep("Breast", 8),
      rep("Prostate", 8),
      rep("Breast", 8)
    ),
    sub(
      " cells$",
      "",
      read.csv(file.path(
        OUT_PATH,
        "xeno_report_GSE240469_1.csv"
      ))$source_name_ch1
    )
  ),

  # GSE273176
  process_gse_report(
    "GSE273176",
    1,
    "EPICv2",
    c(rep("human", 6), rep("PDX", 9)),
    c(rep("Lung", 3), rep("Breast", 3), rep("CRC", 9)),
    c(rep("A549", 3), rep("MDA-MB-231", 3), rep("HCT116", 9))
  ),

  # GSE308997
  process_gse_report("GSE308997", 1, "EPICv1", "PDX", "AML", "AML PDX"),

  # GSE289988
  process_gse_report(
    "GSE289988",
    1,
    "EPICv1",
    c("human", "PDX", rep("human", 7)),
    "LBCL",
    c("LBCL", "LBCL PDX", rep("LBCL", 7))
  ),

  # GSE165050
  process_gse_report(
    "GSE165050",
    1,
    "EPICv1",
    c(rep("PDX", 8), "mouse", "PDX"),
    c(rep("Ovarian", 8), "control", "Ovarian"),
    c(rep("HGSOC PH039", 8), "control", "HGSOC PH039")
  ),

  # GSE271621
  process_gse_report(
    "GSE271621",
    1,
    "EPICv1",
    c(rep("human", 9), rep("PDX", 30)),
    "Glioma",
    sub(
      "_.*",
      "",
      read.csv(file.path(OUT_PATH, "xeno_report_GSE271621_1.csv"))$title
    )
  ),

  process_gse_report(
    "GSE271621",
    2,
    "EPICv2",
    c(rep("PDX", 4), rep("human", 2)),
    "Glioma",
    sub(
      "_.*",
      "",
      read.csv(file.path(OUT_PATH, "xeno_report_GSE271621_2.csv"))$title
    )
  ),

  # GSE240412
  process_gse_report(
    "GSE240412",
    1,
    "EPICv1",
    c(rep("human", 10), rep("PDX", 8)),
    c(
      "control",
      rep("Prostate", 5),
      rep("Breast", 2),
      rep("Prostate", 2),
      rep("Breast", 8)
    ),
    sub(
      "_.*",
      "",
      read.csv(file.path(OUT_PATH, "xeno_report_GSE240412_1.csv"))$title
    )
  ),

  # GSE227695
  process_gse_report(
    "GSE227695",
    1,
    "EPICv1",
    c(rep("PDX", 7), "human"),
    "Prostate",
    c(rep("LuCaP", 7), "MSKCC EF1")
  )
)

# --- Final Merge ---
# Filter out any NULLs from missing files and bind into one DF
final_report <- results_list |>
  purrr::compact() |>
  dplyr::bind_rows() %>%
  mutate(across(tail(names(.), 7), ~ .x * 100))

# Save final result
write.csv(
  final_report,
  file.path(OUT_PATH, "xeno_report.csv"),
  row.names = FALSE
)
