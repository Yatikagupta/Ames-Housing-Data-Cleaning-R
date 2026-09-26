# Ames-Housing-Data-Cleaning-R
End-to-end data cleaning, preprocessing, and exploratory data analysis (EDA) of the Ames Housing dataset using R, featuring missing value imputation, Winsorization, log transformations, and publication-ready visualizations.
# Ames Housing Data Cleaning & Exploratory Data Analysis (R)

## Overview
This repository contains a complete, reproducible data cleaning, preprocessing, and exploratory data analysis (EDA) pipeline for real estate property records using the **Ames Housing Dataset** in **R**. 

The project addresses common real-world data challenges, including structural non-responses, spatial missing values, extreme price skewness, and high-leverage outliers, preparing the dataset for downstream predictive modeling.

## Key Technical Highlights
- **Language & Frameworks:** R, `tidyverse`, `ggplot2`, `corrplot`, `naniar`, `scales`, `gridExtra`
- **Structural Missingness Handling:** Recoded architectural non-existence (`NA`s in garage, basement, pool, alley) into explicit category levels.
- **Group-Wise Spatial Imputation:** Imputed missing continuous values (`lot.frontage`) using neighborhood-stratified medians.
- **Outlier Mitigation:** Applied percentile capping (1%/99% Winsorization) to high-leverage spatial features (`lot.area`, `gr.liv.area`).
- **Feature Normalization:** Applied natural log transformations (`log(saleprice)`) to correct severe target right-skewness and Min-Max scaling for linear modeling suitability.
- **Visual Evidence:** Publication-ready density distribution histograms and upper-triangle correlation matrices.

## Repository Contents
- `script.R`: Complete, bug-fixed R processing script.
- `Figure1_Price_Distribution.png`: Histograms comparing raw vs. log-transformed property prices.
- `Figure2_Correlation_Matrix.png`: Heatmap highlighting primary drivers of property price.
- `Report.docx`: Final comprehensive technical project report.

## Summary Statistics
- **Total Dataset Size:** 2,930 observations × 83 attributes
- **Mean Sale Price:** $180,796.10
- **Median Sale Price:** $160,000.00
- **Log Mean Price:** 12.02
