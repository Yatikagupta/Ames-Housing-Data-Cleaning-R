# Ames Housing Data Science Capstone Project
### End-to-End Analytics, Statistical Analysis & Predictive Modeling in R

---

## 📌 Project Overview

This repository contains the complete end-to-end data science capstone project utilizing the **Ames Housing Dataset** ($N = 2,930$ observations, $81$ attributes). The project spans a 4-week analytical workflow in **R**, covering data preprocessing and feature engineering, exploratory data visualization, inferential statistical hypothesis testing, and regularized predictive machine learning modeling.

The primary goal of this project is to transform complex, multi-dimensional real estate metrics into actionable business intelligence and automated valuation models (AVMs) suitable for property assessors, real estate investors, and financial risk managers.

---

## 📁 Repository Structure & File Layout

```text
.
├── .gitignore                          # Git ignore configuration
├── README.md                           # Master repository documentation
├── data_cleaning.R                     # Week 1: Data preprocessing & cleaning pipeline
├── week2_visualizations.R              # Week 2: High-resolution visualization generation script
├── week3_modeling.R                    # Week 3: Statistical testing & predictive modeling script
│
├── Figure1_Distribution_Analysis.png   # Dual histogram/density plot (Raw vs Log Sale Price)
├── Figure2_LivingArea_vs_Price.png     # Scatter plot (Living Area vs Price by Quality)
├── Figure3_Neighborhood_Volatility.png # Combined Violin/Boxplot (Top 10 Neighborhoods)
├── Figure4_Historical_Price_Trends.png # Time-series LOESS smoothing (1900-2010 Construction Trends)
├── Figure5_Market_Composition.png      # 100% Stacked Bar Chart (Sale Conditions across Quality)
├── Week3_Model_Diagnostics.png         # Residuals vs Fitted & Normal Q-Q diagnostic plots
│
├── Week2_Data_Visualization_Report.docx# Week 2 visual report deliverable
├── Week3_Predictive_Modeling_Report.docx# Week 3 modeling report deliverable
└── Final_Comprehensive_Data_Analysis_Report.docx # Week 4 final capstone executive report
```

---

## 🗓️ Weekly Analytical Workflow Breakdown

### 🧹 Week 1: Data Preprocessing & Feature Engineering
* **Data Sanitization:** Imputed missing values across $81$ columns without listwise deletion by recoding structural absence (e.g., `No Garage`, `No Basement`).
* **Outlier Filtering:** Removed non-typical properties exceeding $4,000\text{ sq. ft.}$ exhibiting distressed sale conditions.
* **Target Normalization:** Created `saleprice_log` via natural log transformation ($\ln(\text{SalePrice})$) to eliminate severe right-skewness and stabilize variance.

### 📊 Week 2: Exploratory Data Visualization & Insights
Generated five publication-ready figures using `ggplot2`, `gridExtra`, and `viridis` palettes:
1. **Target Distribution Analysis:** Dual histogram/density comparison verifying normalization.
2. **Size vs. Valuation ROI:** Bivariate scatter plot showing how quality ratings amplify returns per square foot.
3. **Sub-Market Volatility:** Violin/boxplot combination showcasing price dispersion across top 10 neighborhoods.
4. **Historical Price Trends:** LOESS smoothed time-series tracking structural appreciation from 1900 to 2010.
5. **Market Composition:** Stacked bar chart highlighting new construction prevalence in top-tier quality homes.

### 🧪 Week 3: Inferential Statistics & Predictive Modeling
* **Hypothesis Testing:**
  * *Pearson Correlation:* Validated strong positive linear relationship between living area and log price ($r = 0.71, p < 2.2 \times 10^{-16}$).
  * *One-Way ANOVA:* Confirmed significant neighborhood sub-market valuation effects ($F = 114.2, p < 2.2 \times 10^{-16}$).
* **Predictive Machine Learning:**
  * Split data into an **80/20 train-test partition** with **10-fold cross-validation**.
  * Trained **Multiple Linear Regression (OLS)** baseline vs. **Regularized Lasso Regression ($L_1$ Penalty)**.
  * Executed residual diagnostics (Residuals vs Fitted, Normal Q-Q plots) confirming homoscedasticity and Gaussian error distribution.

### 📝 Week 4: Capstone Integration & Executive Deliverables
* Consolidated all code, statistical outputs, graphical visuals, and business implications into a comprehensive final Word report (`Final_Comprehensive_Data_Analysis_Report.docx`).

---

## 📈 Key Findings & Predictive Model Performance

| Model Architecture | Test RMSE | Test MAE | Test $R^2$ Variance Explained |
| :--- | :---: | :---: | :---: |
| **Multiple Linear Regression (OLS)** | $0.152$ | $0.108$ | $83.4\%$ |
| **Regularized Lasso Regression (L1)** | **$0.148$** | **$0.104$** | **$84.2\%$** |

* **Lasso Superiority:** $L_1$ regularization effectively penalized redundant feature coefficients, achieving superior generalization on unseen testing data with a lower Root Mean Squared Error ($\text{RMSE} = 0.148$) and explaining **$84.2\%$ of variance** in property values.
* **Valuation Impact:** On average, predictions deviate by only $\sim 10.4\%$ ($\text{MAE} = 0.104$ on log scale), providing a reliable automated appraisal framework.

---

## 🛠️ Tech Stack & R Dependencies

* **Language:** R (v4.0+)
* **Environment:** RStudio
* **Core Libraries:**
  * `tidyverse` (`dplyr`, `ggplot2`, `readr`, `stringr`) — Data manipulation & plotting
  * `caret` — Machine learning training & cross-validation pipeline
  * `glmnet` — Regularized linear models (Lasso / Ridge)
  * `gridExtra` — Multi-panel figure arrangements
  * `viridis` & `RColorBrewer` — Accessible color palettes
  * `scales` — Visual scale formatting
  * `car` & `broom` — Statistical testing & model diagnostics
  * `pacman` — Package management

---

## 🚀 How to Run & Reproduce

To reproduce the analysis and regenerate all figures and model metrics, execute the R scripts sequentially in RStudio:

```R
# Step 1: Preprocess data and clean dataset
source("data_cleaning.R")

# Step 2: Generate and save all 5 Week 2 PNG visualizations
source("week2_visualizations.R")

# Step 3: Execute statistical hypothesis tests and train predictive models
source("week3_modeling.R")
```

---
*Created as part of the Ames Housing Data Science Capstone Project.*
