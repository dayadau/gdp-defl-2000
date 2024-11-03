# Executive Summary
The graph is used for the Development Economics lecture therefore the project cannot be publicly on GitHub. 

## Objectives
Aim to observe the differences in GDP deflation development grouped by income level in 2000. That is, freeze the development of the countries and observe only the GDP deflation development.

## Methodology
- **Preparation:** The data for the income level 2000 is provided by the professor.
- **Data Extraction:** The team already preprocessed the GDP deflation dataset, so we loaded and filtered the needed attributes.
- **Data Cleaning:** Filter out a group of countries with only a maximum of 1 observation.
- **Data Manipulation:** Imputation value for missing variable using linear regression.
- **Visualisation:** Building mean and visualise the graph from 2000 to 2020.

## Skills
Libraries used in R:
- dplyr
- ggplot2
- simputation
- imputeTS
- readr
- WDI

## Discussion
First, test with both Linear Regression and Spline Interpolation for imputation. However, decided to choose Linear Regression because:
- Flexible to add more predictors i.e., interest rates.
- Reuseability: adapt to every year changes without overfitting or smoothing the graph.
