# ==============================================================================
# R SCRIPT: DATA CLEANING AND PRELIMINARY ANALYSIS (WORKING VERSION)
# ==============================================================================

# 1. SETUP & LIBRARIES
# ------------------------------------------------------------------------------
required_packages <- c("tidyverse", "naniar", "corrplot", "scales", "gridExtra")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(tidyverse)
library(naniar)
library(corrplot)
library(scales)
library(gridExtra)

# 2. DATA INGESTION & COLUMN ALIGNMENT
# ------------------------------------------------------------------------------
cat("--- Ingesting Raw Dataset ---\n")
url <- "https://www.openintro.org/data/csv/ames.csv"
raw_data <- read.csv(url)

# Convert all column names: lowercase and replace spaces/underscores with dots
names(raw_data) <- tolower(names(raw_data))
names(raw_data) <- gsub("[_ ]", ".", names(raw_data))

# Map column names to standard variables used throughout the script
if ("price" %in% names(raw_data)) {
  raw_data$saleprice <- raw_data$price
}

cat("Dataset Size:", nrow(raw_data), "rows and", ncol(raw_data), "columns\n")

# 3. DATA CLEANING & PREPROCESSING
# ------------------------------------------------------------------------------
cat("--- Cleaning Data & Handling Missing Values ---\n")

# A. Handle Missing Values safely
df_clean <- raw_data %>%
  mutate(
    alley        = ifelse(is.na(alley), "No_Alley", alley),
    bsmt.qual    = ifelse(is.na(bsmt.qual), "No_Basement", bsmt.qual),
    garage.type  = ifelse(is.na(garage.type), "No_Garage", garage.type),
    pool.qc      = ifelse(is.na(pool.qc), "No_Pool", pool.qc),
    fence        = ifelse(is.na(fence), "No_Fence", fence),
    fireplace.qu = ifelse(is.na(fireplace.qu), "No_Fireplace", fireplace.qu)
  ) %>%
  group_by(neighborhood) %>%
  mutate(lot.frontage = ifelse(is.na(lot.frontage), median(lot.frontage, na.rm = TRUE), lot.frontage)) %>%
  ungroup()

# B. Outlier Capping (Winsorization)
cap_outliers <- function(x) {
  if (is.null(x)) return(x)
  qnt <- quantile(x, probs = c(0.01, 0.99), na.rm = TRUE)
  x[x < qnt[1]] <- qnt[1]
  x[x > qnt[2]] <- qnt[2]
  return(x)
}

df_clean$gr.liv.area <- cap_outliers(df_clean$gr.liv.area)
df_clean$lot.area    <- cap_outliers(df_clean$lot.area)

# C. Feature Transformations
df_clean <- df_clean %>%
  mutate(
    saleprice_log   = log(saleprice),
    lot.area_scaled = (lot.area - min(lot.area, na.rm = TRUE)) / 
      (max(lot.area, na.rm = TRUE) - min(lot.area, na.rm = TRUE))
  )

# 4. EXPLORATORY DATA ANALYSIS (EDA) & VISUALIZATIONS
# ------------------------------------------------------------------------------
cat("--- Generating Exploratory Outputs ---\n")

# A. Summary Statistics
summary_table <- df_clean %>%
  summarise(
    Mean_Price   = mean(saleprice, na.rm = TRUE),
    Median_Price = median(saleprice, na.rm = TRUE),
    SD_Price     = sd(saleprice, na.rm = TRUE),
    IQR_Price    = IQR(saleprice, na.rm = TRUE),
    Min_Price    = min(saleprice, na.rm = TRUE),
    Max_Price    = max(saleprice, na.rm = TRUE)
  )
print(summary_table)

# B. Visual 1: Raw vs Log Price Distribution
p_raw <- ggplot(df_clean, aes(x = saleprice)) +
  geom_histogram(aes(y = after_stat(density)), bins = 35, fill = "#1F77B4", color = "white", alpha = 0.8) +
  geom_density(color = "#D62728", linewidth = 1) +
  scale_x_continuous(labels = dollar_format()) +
  theme_classic() +
  labs(
    title = "Raw Price Distribution",
    subtitle = "Right-skewed target variable",
    x = "Property Sale Price ($)",
    y = "Density"
  )

p_log <- ggplot(df_clean, aes(x = saleprice_log)) +
  geom_histogram(aes(y = after_stat(density)), bins = 35, fill = "#2CA02C", color = "white", alpha = 0.8) +
  geom_density(color = "#D62728", linewidth = 1) +
  theme_classic() +
  labs(
    title = "Log-Transformed Price",
    subtitle = "Normalized bell curve",
    x = "Log(Sale Price)",
    y = "Density"
  )

# C. Visual 2: Correlation Heatmap
# Select available numeric columns dynamically
numeric_vars <- df_clean %>% 
  select(where(is.numeric)) %>%
  select(any_of(c("saleprice", "price", "area", "gr.liv.area", "gr_liv_area", 
                  "lot.area", "lot_area", "overall.qual", "overall_qual", 
                  "year.built", "year_built", "total.bsmt.sf", "total_bsmt_sf")))

cor_matrix <- cor(numeric_vars, use = "complete.obs")

corrplot(cor_matrix, method = "color", type = "upper", 
         addCoef.col = "black", tl.col = "black", tl.srt = 45,
         title = "\nFeature Correlation Matrix", mar = c(0, 0, 2, 0))

cat("\n--- Execution Complete! All plots rendered successfully. ---\n")
