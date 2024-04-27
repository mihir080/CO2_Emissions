# CO2 Emissions from Food Consumption Analysis

## Overview

This script aims to analyze CO2 emissions from food consumption across different countries. It provides insights into the relationship between food consumption patterns and associated CO2 emissions, as well as comparisons between different food categories and countries.

## Dependencies

This script utilizes several R packages for data manipulation, visualization, and statistical analysis. 

The required packages are:

- `readr`
- `tidyverse`
- `ggplot2`
- `ggthemes`
- `broom`
- `knitr`
- `plotly`
- `sf`
- `rnaturalearthdata`
- `rnaturalearth`

The script automatically installs the required packages and loads them.

## Dataset

Ensure that you have the dataset named `Dataset_Foodconsumption.csv` available in your working directory. This dataset should contain relevant information about food consumption, CO2 emissions, countries, and food categories.

## Usage

1. __Installation of Packages__: The script automatically checks for and installs required packages if they are not already installed.
2. __Loading Data__: The dataset is loaded into R using `read_csv()` function from `readr` package. Ensure the dataset is correctly loaded and inspect its structure using `head()` and `summary()` functions.
3. __Data Visualization__: The script includes various visualizations to explore the data. It utilizes box plots, bar charts, and density plots to compare CO2 emissions and consumption across different food categories and countries.
4. __Analysis__: The script conducts descriptive statistics, calculates emissions per unit of food consumption, identifies top consuming countries for each food category, and compares consumption and emissions between animal and non-animal products.
5. __Output__: The script generates visualizations and tables to summarize the analysis findings. It provides insights into the impact of food consumption on CO2 emissions.

## Output

The output includes visualizations and tables generated during the analysis. These outputs help in understanding the relationships between food consumption, CO2 emissions, food categories, and countries.

## Note

- Ensure that the R environment is properly set up, and all required packages are installed before running the script. Additionally, review the dataset and adjust the script as needed based on specific data characteristics.
- The `Script.R` has the code for the project and `CO2Emissions.Rmd` has the Markdown file with a brief analysis.
