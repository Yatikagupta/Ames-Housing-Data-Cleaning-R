# ==============================================================================
# WEEK 3: STATISTICAL ANALYSIS AND PREDICTIVE MODELING
# Script: week3_modeling.R
# Dataset: Ames Housing (df_clean)
# ==============================================================================

# 1. Load Required Libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, caret, glmnet, car, broom, gridExtra, scales)

# Set Reproducibility Seed
set.seed(42)

# Ensure Log Target is present
sp_col  <- names(df_clean)[grep("price|saleprice", names(df_clean), ignore.case = TRUE)][1]
if (!"saleprice_log" %in% names(df_clean)) {
  df_clean$saleprice_log <- log(df_clean[[sp_col]])
}

# ------------------------------------------------------------------------------
# SECTION 1: HYPOTHESIS TESTING & EXPLORATORY STATISTICAL ANALYSIS
# ------------------------------------------------------------------------------

# Hypothesis Test 1: Correlation between Above Ground Living Area & Log Sale Price
area_col <- names(df_clean)[grep("area|sqft|liv", names(df_clean), ignore.case = TRUE)][1]
cor_test_area <- cor.test(df_clean[[area_col]], df_clean$saleprice_log, method = "pearson")

# Hypothesis Test 2: ANOVA - Neighborhood Effect on Sale Price
neigh_col <- names(df_clean)[grep("neigh", names(df_clean), ignore.case = TRUE)][1]
anova_neigh <- aov(df_clean$saleprice_log ~ df_clean[[neigh_col]])
anova_summary <- summary(anova_neigh)

# Print Hypothesis Test Results to Console
cat("\n--- HYPOTHESIS TEST 1: PEARSON CORRELATION (Area vs Log-Price) ---\n")
print(cor_test_area)

cat("\n--- HYPOTHESIS TEST 2: ONE-WAY ANOVA (Neighborhood Effect) ---\n")
print(anova_summary)

# ------------------------------------------------------------------------------
# SECTION 2: DATA SPLITTING & CROSS-VALIDATION SETUP
# ------------------------------------------------------------------------------

# Select features for predictive modeling
qual_col <- names(df_clean)[grep("qual", names(df_clean), ignore.case = TRUE)][1]
year_col <- names(df_clean)[grep("built|year", names(df_clean), ignore.case = TRUE)][1]

model_df <- df_clean %>%
  select(saleprice_log, 
         Area = .data[[area_col]], 
         Quality = .data[[qual_col]], 
         YearBuilt = .data[[year_col]], 
         Neighborhood = .data[[neigh_col]]) %>%
  drop_na()

# 80/20 Train-Test Split
train_index <- createDataPartition(model_df$saleprice_log, p = 0.80, list = FALSE)
train_data  <- model_df[train_index, ]
test_data   <- model_df[-train_index, ]

# Set up 10-Fold Cross-Validation
cv_control <- trainControl(method = "cv", number = 10)

# ------------------------------------------------------------------------------
# SECTION 3: MODEL BUILDING
# ------------------------------------------------------------------------------

# Model 1: Baseline Multiple Linear Regression (OLS)
lm_model <- train(
  saleprice_log ~ ., 
  data = train_data, 
  method = "lm",
  trControl = cv_control
)

# Model 2: Lasso Regularized Regression (L1) with CV Tuning
lasso_model <- train(
  saleprice_log ~ ., 
  data = train_data, 
  method = "glmnet",
  trControl = cv_control,
  tuneGrid = expand.grid(alpha = 1, lambda = seq(0.0001, 0.1, length = 50))
)

# ------------------------------------------------------------------------------
# SECTION 4: MODEL EVALUATION & TESTING
# ------------------------------------------------------------------------------

# Predictions on Unseen Test Set
lm_preds    <- predict(lm_model, newdata = test_data)
lasso_preds <- predict(lasso_model, newdata = test_data)

# Performance Metrics Function
calc_metrics <- function(actual, predicted) {
  rmse_val <- RMSE(predicted, actual)
  mae_val  <- MAE(predicted, actual)
  r2_val   <- R2(predicted, actual)
  return(c(RMSE = rmse_val, MAE = mae_val, R2 = r2_val))
}

lm_perf    <- calc_metrics(test_data$saleprice_log, lm_preds)
lasso_perf <- calc_metrics(test_data$saleprice_log, lasso_preds)

perf_comparison <- data.frame(
  Model = c("Multiple Linear Regression (OLS)", "Regularized Lasso Regression"),
  RMSE = c(lm_perf["RMSE"], lasso_perf["RMSE"]),
  MAE = c(lm_perf["MAE"], lasso_perf["MAE"]),
  R2 = c(lm_perf["R2"], lasso_perf["R2"])
)

cat("\n--- MODEL PERFORMANCE COMPARISON (TEST SET) ---\n")
print(perf_comparison)

# ------------------------------------------------------------------------------
# SECTION 5: MODEL DIAGNOSTICS & PLOTS
# ------------------------------------------------------------------------------

# Residual Analysis Plots
diag_df <- data.frame(
  Fitted = predict(lm_model, newdata = train_data),
  Residuals = residuals(lm_model$finalModel)
)

p_res <- ggplot(diag_df, aes(x = Fitted, y = Residuals)) +
  geom_point(alpha = 0.4, color = "#2B5C8F") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  labs(title = "Residuals vs. Fitted Values", x = "Fitted Log(Sale Price)", y = "Residuals")

p_qq <- ggplot(diag_df, aes(sample = Residuals)) +
  stat_qq(color = "#2E8B57", alpha = 0.5) +
  stat_qq_line(color = "red", linewidth = 1) +
  labs(title = "Normal Q-Q Plot of Residuals", x = "Theoretical Quantiles", y = "Sample Quantiles")

fig_diag <- grid.arrange(p_res, p_qq, ncol = 2)

# Save Diagnostic Plots
png("Week3_Model_Diagnostics.png", width = 3000, height = 1500, res = 300)
grid.draw(fig_diag)
dev.off()

cat("\n--- Completed! Week3_Model_Diagnostics.png saved to working directory --- \n")
