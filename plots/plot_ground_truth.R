# ---- LIBRARIES ----
library(ArrayExpress)
library(dplyr)
library(ggplot2)

# ---- DATA PREPARATION ----
OUT_PATH <- "out"
dir.create(OUT_PATH, showWarnings = FALSE)

experiment <- "E-MTAB-16743"
idat_path <- paste0("idat/", experiment)
dir.create(idat_path, showWarnings = FALSE)

ae <- getAE(
  experiment,
  path = idat_path,
  type = "full"
)

ground_truth_report <- run_xeno(idat_path, 8)

ground_truth_meta <- read.table(
  file.path(idat_path, paste0(experiment, ".sdrf.txt")),
  sep = "\t",
  header = TRUE
) |>
  mutate(sample = substring(Assay.Name, 1, 19)) |>
  distinct(sample, .keep_all = TRUE) |>
  left_join(ground_truth_report, by = "sample") %>%
  mutate(across(tail(names(.), 7), ~ .x * 100))

write.csv(
  ground_truth_meta,
  file.path(OUT_PATH, "ground_truth_meta.csv"),
  row.names = FALSE
)

# ---- SET THEME ----
custom_theme <- theme_bw() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.text.x = element_text(size = 10, vjust = 0.5),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12, face = "bold")
  )

# ---- VALIDATION PLOT ----
r_value <- ground_truth_meta %>%
  lm(mouse_fraction ~ Factor.Value.mouse.fraction., data = .) |>
  summary() |>
  {
    \(x) sqrt(x$adj.r.squared)
  }()

p1 <- ground_truth_meta |>
  ggplot(aes(Factor.Value.mouse.fraction., mouse_fraction)) +
  geom_line() +
  geom_point() +
  geom_errorbar(
    aes(
      ymin = mouse_fraction - sem_mouse_signal,
      ymax = mouse_fraction + sem_mouse_signal
    ),
    width = 5,
    alpha = 0.8
  ) +
  geom_abline(intercept = 0, slope = 1, color = "grey") +
  scale_y_continuous(limits = c(-3, 103), breaks = seq(0, 100, 10)) +
  scale_x_continuous(limits = c(-3, 103), breaks = seq(0, 100, 10)) +
  labs(
    x = "Mouse fraction (ground truth) [%]",
    y = "Mouse fraction (predicted) [%]"
  ) +
  annotate(
    geom = "text",
    x = 10,
    y = 100,
    size = 5,
    label = paste("r == ", round(r_value, 3)),
    parse = TRUE
  ) +
  custom_theme

p1

ggsave(
  file.path(OUT_PATH, "ground_truth_validation.pdf"),
  p1,
  width = 5,
  height = 5
)
message("--- Ground truth validation plot saved to 'out/' ---")
