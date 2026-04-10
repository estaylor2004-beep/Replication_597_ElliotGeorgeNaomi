/*****************************************************************************
* CORE INTEGRATION TOOLS
*****************************************************************************/

// GitHub package manager for Stata
*! version 2.3.0, 20sep2021
net install github, from("https://haghish.github.io/github/") replace
github install haghish/github, replace

// R integration: Execute R code from within Stata
// use fork of https://github.com/haghish/rcall, because of CRAN mirror issue, see Pull Request https://github.com/haghish/rcall/pull/41
*! version 3.1.0, 20sep2021
github install wmutschl/rcall, stable

// Install required R packages using rcall (R version 4.5.1 or later)
// Note: You need to have installed at least one R package manually before running this script
// to ensure your user library is properly configured for rcall installations, e.g. install.packages("readstata13")
rcall: install.packages(c("readstata13", "countrycode", "haven", "tidyverse", "ggplot2", "ggrepel", "patchwork", "scales", "peacesciencer", "stevemisc", "fixest", "modelsummary", "huxtable", "tinytable", "knitr", "WDI"), repos="https://cloud.r-project.org/")

// Stata wrapper for R's countrycode package via rcall
// use fork of https://github.com/luispfonseca/stata-rcallcountrycode, because of CRAN mirror issue, see Pull Request https://github.com/luispfonseca/stata-rcallcountrycode/pull/5
*! version 0.1.11, 10mar2021
github install wmutschl/stata-rcallcountrycode

/*****************************************************************************
* REGRESSION AND ECONOMETRIC TOOLS
*****************************************************************************/

// Publication-quality regression tables and export to LaTeX, HTML, or text
*! version 3.31  26apr2022  Ben Jann
ssc install estout, replace

// Fast tools for large datasets: efficient sorting, merging, and fixed effects operations (required by reghdfe)
*! version 2.49.1 08aug2023
ssc install ftools, replace

// High-dimensional fixed effects regression with multiple levels of clustering
*! version 6.12.3 08aug2023
ssc install reghdfe, replace

// Poisson Pseudo-Maximum Likelihood with high-dimensional fixed effects for count/gravity models
*! version 2.3.0 25feb2021
*! Authors: Sergio Correia, Paulo Guimarães, Thomas Zylkin
*! URL: https://github.com/sergiocorreia/ppmlhdfe
ssc install ppmlhdfe, replace

// Panel data regression with Driscoll-Kraay standard errors for spatial/temporal correlation
*! xtscc, version 1.4, Daniel Hoechle, 01dec2017
ssc install xtscc, replace

// Extended Mata library with additional mathematical and statistical functions
*! Distribution-Date: 20250630
ssc install moremata, replace

// Mat2txt: Convert matrices to text files
*! 1.1.2 Ben Jann 24 Nov 2004
ssc install mat2txt, replace

/*****************************************************************************
* DATA MANIPULATION TOOLS
*****************************************************************************/

// Winsorize variables at specified percentiles to handle outliers
*! Inspirit of -winsor-(NJ Cox) and -winsorizeJ-(J Caskey)
*! Lian Yujun, arlionn@163.com, 2013-12-25
*! 1.1 2014.12.16
ssc install winsor2, replace

// Additional egen functions for data manipulation and variable creation
*! Distribution-Date: 20190124
ssc install egenmore, replace

// Country name/code conversion (alternative to R-based solution)
*! version 2.1.6  12aug2013
ssc install kountry, replace

/*****************************************************************************
* VISUALIZATION TOOLS
*****************************************************************************/

// Combine graphs with a single common legend
*! version 1.0.5  02jun2010
net install grc1leg, from(http://www.stata.com/users/vwiggins/) replace

// Enhanced version of grc1leg with additional options for combining graphs
*! version 2.26 (4Nov2023), by Mead Over
ssc install grc1leg2, replace

// Geographical maps and spatial visualizations
*! version 1.3.5  17sep2024  Ben Jann
ssc install geoplot, replace

// Color palettes and schemes for graphs and visualizations
*! Distribution-Date: 20240705
ssc install palettes, replace

// Color space utilities (required by palettes)
*! Distribution-Date: 20240705
ssc install colrspace, replace

// Binned scatter plots for visualizing relationships in large datasets
*! version 7.02  24nov2013  Michael Stepner, stepner@mit.edu
ssc install binscatter, replace

// Export to LaTeX format
*! texsave 1.6.1 22may2023 by Julian Reif
ssc install texsave, replace
