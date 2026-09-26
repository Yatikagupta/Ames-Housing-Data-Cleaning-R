# ==============================================================================
# WEEK 2: DATA VISUALIZATION AND INSIGHT COMMUNICATION
# Project: Ames Housing Dataset Analysis & Visualization
# Deliverables: 5 High-Resolution Publication-Ready Plots
# ==============================================================================

# 1. Load Required Libraries
library(tidyverse)
library(scales)
library(gridExtra)
library(viridis)

# 2. Set Global ggplot2 Visual Theme
theme_set(
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#111111"),
    plot.subtitle = element_text(size = 10, color = "#555555"),
    plot.caption = element_text(size = 8, face = "italic", color = "#777777"),
    axis.title = element_text(face = "bold", size = 10),
    legend.position = "top",
    panel.grid.minor = element_blank()
  )
)

# 3. Dynamic Column Mapping
cols <- names(df_clean)
sp_col   <- cols[grepl("price|saleprice", cols, ignore.case = TRUE)][1]
log_col  <- cols[grepl("log", cols, ignore.case = TRUE)][1]
area_col <- cols[grepl("area|sqft|liv", cols, ignore.case = TRUE)][1]
qual_col <- cols[grepl("qual", cols, ignore.case = TRUE)][1]
neigh_col<- cols[grepl("neigh", cols, ignore.case = TRUE)][1]
year_col <- cols[grepl("built|year", cols, ignore.case = TRUE)][1]
bldg_col <- cols[grepl("bldg|type|style", cols, ignore.case = TRUE)][1]
cond_col <- cols[grepl("cond", cols, ignore.case = TRUE)][1]

if(is.na(log_col)) {
  df_clean$saleprice_log <- log(df_clean[[sp_col]])
  log_col <- "saleprice_log"
}

# ------------------------------------------------------------------------------
# FIGURE 1: Target Variable Distribution Analysis
# ------------------------------------------------------------------------------
p1_raw <- ggplot(df_clean, aes(x = .data[[sp_col]])) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, fill = "#2B5C8F", alpha = 0.7, color = "white") +
  geom_density(color = "#D9534F", linewidth = 1) +
  scale_x_continuous(labels = label_dollar(scale = 1e-3, suffix = "K")) +
  labs(title = "A. Raw Sale Price Distribution", x = "Sale Price ($ USD)", y = "Density")

p1_log <- ggplot(df_clean, aes(x = .data[[log_col]])) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, fill = "#2E8B57", alpha = 0.7, color = "white") +
  geom_density(color = "#D9534F", linewidth = 1) +
  labs(title = "B. Log-Transformed Sale Price", x = "Log(Sale Price)", y = "Density")

fig1 <- grid.arrange(p1_raw, p1_log, ncol = 2)
ggsave("Figure1_Distribution_Analysis.png", fig1, width = 12, height = 5, dpi = 300)

# ------------------------------------------------------------------------------
# FIGURE 2: Bivariate Scatter Analysis (Living Area vs. Price)
# ------------------------------------------------------------------------------
fig2 <- ggplot(df_clean, aes(x = .data[[area_col]], y = .data[[sp_col]] / 1000, color = factor(.data[[qual_col]]))) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed", linewidth = 0.8) +
  scale_color_viridis_d(name = "Overall Quality Rating", option = "magma") +
  scale_y_continuous(labels = label_dollar(suffix = "K")) +
  scale_x_continuous(labels = label_comma()) +
  labs(title = "Living Area vs. Sale Price", x = "Living Area (Sq. Ft.)", y = "Sale Price ($ USD in K)")

ggsave("Figure2_LivingArea_vs_Price.png", fig2, width = 10, height = 6, dpi = 300)

# ------------------------------------------------------------------------------
# FIGURE 3: Sub-Market Valuation Volatility (Top 10 Neighborhoods)
# ------------------------------------------------------------------------------
top_10_neigh <- df_clean %>% count(.data[[neigh_col]]) %>% top_n(10, n) %>% pull(.data[[neigh_col]])
df_top10 <- df_clean %>% filter(.data[[neigh_col]] %in% top_10_neigh)

fig3 <- ggplot(df_top10, aes(x = reorder(.data[[neigh_col]], .data[[sp_col]], FUN = median), y = .data[[sp_col]] / 1000, fill = .data[[neigh_col]])) +
  geom_violin(alpha = 0.4, color = NA) +
  geom_boxplot(width = 0.2, color = "#222222", outlier.size = 1, alpha = 0.8) +
  coord_flip() +
  scale_fill_viridis_d(option = "mako", guide = "none") +
  scale_y_continuous(labels = label_dollar(suffix = "K")) +
  labs(title = "Neighborhood Valuation Spread", x = "Neighborhood", y = "Sale Price ($ USD in K)")

ggsave("Figure3_Neighborhood_Volatility.png", fig3, width = 10, height = 6, dpi = 300)

# ------------------------------------------------------------------------------
# FIGURE 4: Historical Time Series Construction Trends
# ------------------------------------------------------------------------------
df_time <- df_clean %>%
  filter(.data[[year_col]] >= 1900) %>%
  group_by(.data[[year_col]], .data[[bldg_col]]) %>%
  summarise(median_price = median(.data[[sp_col]], na.rm = TRUE), count = n(), .groups = "drop") %>%
  filter(count >= 2)

fig4 <- ggplot(df_time, aes(x = .data[[year_col]], y = median_price / 1000, color = .data[[bldg_col]])) +
  geom_line(linewidth = 0.9, alpha = 0.8) +
  geom_smooth(se = FALSE, method = "loess", span = 0.3, linetype = "solid", linewidth = 1.2) +
  scale_y_continuous(labels = label_dollar(suffix = "K")) +
  scale_color_brewer(palette = "Set1", name = "Building Structure Type") +
  labs(title = "Historical Evolution of Housing Valuations", x = "Year Built", y = "Median Price ($ USD in K)")

ggsave("Figure4_Historical_Price_Trends.png", fig4, width = 11, height = 6, dpi = 300)

# ------------------------------------------------------------------------------
# FIGURE 5: Categorical Proportion & Market Composition
# ------------------------------------------------------------------------------
fig5 <- ggplot(df_clean, aes(x = factor(.data[[qual_col]]), fill = .data[[cond_col]])) +
  geom_bar(position = "fill", alpha = 0.85) +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_brewer(palette = "Spectral", name = "Sale Condition") +
  labs(title = "Sale Condition Breakdown by Quality", x = "Quality Rating", y = "Percentage Composition")

ggsave("Figure5_Market_Composition.png", fig5, width = 10, height = 5.5, dpi = 300)
