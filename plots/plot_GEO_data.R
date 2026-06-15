# ---- LIBRARIES ----
library(dplyr)
library(ggplot2)
library(stringr)

# ---- DATA PREPARATION ----
source("plots/get_GEO_data.R")
source("plots/analyze_GEO_data.R")
source("plots/curate_GEO_data.R")

OUT_PATH <- "out"

# Load and clean data
df <- read.csv(file.path(OUT_PATH, "xeno_report.csv")) |>
  dplyr::mutate(
    sample_type = sub("(.)", "\\U\\1", sample_type, perl = TRUE)
  )

# ---- SET THEME ----
# Reusable theme object to keep plots consistent
custom_theme <- theme_bw() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid = element_blank(),
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.text.x = element_text(size = 10, vjust = 0.5),
    axis.text.y = element_text(size = 8),
    axis.title = element_text(size = 10, face = "bold"),
    axis.title.y = element_blank(),
    panel.grid.minor = element_blank()
  )

# ---- PLOTTING FUNCTION ----
create_mouse_boxplot <- function(data, x_var, title_text, fill_var = NULL) {
  fill_var <- fill_var %||% x_var # Default fill to x variable if not specified

  ggplot(
    data,
    aes(x = .data[[x_var]], y = mouse_fraction, fill = .data[[fill_var]])
  ) +
    geom_boxplot(outlier.shape = NA) +
    geom_jitter(width = 0.15, size = 1, alpha = 0.4) +
    scale_y_continuous(limits = c(-1, 101), breaks = seq(0, 100, 25)) +
    labs(
      title = title_text,
      x = stringr::str_to_title(gsub("_", " ", x_var)),
      y = "Mouse fraction (predicted) [%]"
    ) +
    custom_theme
}

# ---- 1. All Experiments ----
p1 <- create_mouse_boxplot(df, "sample_type", "All experiments")
p1
ggsave(
  file.path(OUT_PATH, "mouse_analysis_geo.pdf"),
  p1,
  width = 2.5,
  height = 5
)

# ---- 2. Platform Comparison ----
p2 <- create_mouse_boxplot(df, "sample_type", "Comparison by Platform") +
  facet_wrap(~platform)
p2
ggsave(
  file.path(OUT_PATH, "mouse_analysis_geo_platform.pdf"),
  p2,
  width = 5,
  height = 8
)

# ---- 3. Human vs PDX by Tumor Type ----
# Human
p3 <- df |>
  filter(sample_type == "Human") |>
  create_mouse_boxplot("tumor_type", "Human Samples")
p3
ggsave(
  file.path(OUT_PATH, "mouse_analysis_geo_human_tumors.pdf"),
  p3,
  width = 6,
  height = 5
)

# PDX
p4 <- df |>
  filter(sample_type == "PDX") |>
  create_mouse_boxplot("tumor_type", "PDX Samples")
p4
ggsave(
  file.path(OUT_PATH, "mouse_analysis_geo_pdx_tumors.pdf"),
  p4,
  width = 6,
  height = 5
)

# ---- 4. Results by GSE (Experiment) ----
# Helper for angled labels on these specific plots
gse_theme <- theme(axis.text.x = element_text(angle = 45, hjust = 1))

p5 <- df |>
  filter(sample_type == "Human") |>
  create_mouse_boxplot("gse", "Human Samples by Experiment") +
  gse_theme
p5
ggsave(
  file.path(OUT_PATH, "mouse_analysis_geo_human_experiments.pdf"),
  p5,
  width = 5,
  height = 5
)

p6 <- df |>
  filter(sample_type == "PDX") |>
  create_mouse_boxplot("gse", "PDX Samples by Experiment") +
  gse_theme
p6
ggsave(
  file.path(OUT_PATH, "mouse_analysis_geo_pdx_experiments.pdf"),
  p6,
  width = 5,
  height = 5
)

message("--- All plots generated and saved to 'out/' ---")
