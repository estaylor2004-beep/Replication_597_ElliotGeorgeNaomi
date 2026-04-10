/*
* Replication Package for "The Price of War"
* Authors: Jonathan Federle, Andre Meier, Gernot J. Müller, Willi Mutschler, Moritz Schularick
*
* See README for instructions to install necessary dependencies.
*/
display "Starting main.do at: " c(current_date) + " " + c(current_time)


/*****************************************************************************
* 0a. Project Configuration
*
* Set root directory of the project:
* - "~" is /Users/$USER on Mac, /home/$USER on Linux, and C:\Users\%USERNAME% on Windows
* - use "/" instead of "\" to separate folders even on Windows
* - cap evades possible errors of the cd command if a directory does not exist
*
*****************************************************************************/
// Set project directory as working directory (adjust as needed)
cap cd "~/Downloads/238484"
cap cd "~/Documents/price-of-war"
global DIR_PROJ = "`c(pwd)'"

// Font face used in figures
graph set window fontface "Palatino"


/*****************************************************************************
* 0b. Miscellaneous variable definitions and procedures
*
* Do not adjust
*****************************************************************************/
global DIR_DATA_RAW "${DIR_PROJ}/data/01_raw"
global DIR_DATA_PROCESSED "${DIR_PROJ}/data/02_processed"
global DIR_DATA_EXPORTS "${DIR_PROJ}/data/03_exports"
global DIR_DATA_TMP "${DIR_PROJ}/data/00_tmp"
global DIR_RESSOURCES "${DIR_PROJ}/ressources"

global DIR_SRC_UTILS "${DIR_PROJ}/src/00_utils"
global DIR_SRC_PROCESS "${DIR_PROJ}/src/01_process"
global DIR_SRC_EXPORTS "${DIR_PROJ}/src/02_export"

* Check if directories exist
cap mkdir "${DIR_DATA_TMP}"
cap mkdir "${DIR_DATA_PROCESSED}"
cap mkdir "${DIR_DATA_EXPORTS}
cap mkdir "${DIR_DATA_EXPORTS}/tables"
cap mkdir "${DIR_DATA_EXPORTS}/tables/descriptives"
cap mkdir "${DIR_DATA_EXPORTS}/tables/predictability"
cap mkdir "${DIR_DATA_EXPORTS}/figures"
cap mkdir "${DIR_DATA_EXPORTS}/figures/descriptives"
cap mkdir "${DIR_DATA_EXPORTS}/figures/descriptives/anticipation"
cap mkdir "${DIR_DATA_EXPORTS}/figures/lp"
cap mkdir "${DIR_DATA_EXPORTS}/figures/lp/heterogeneity"
cap mkdir "${DIR_DATA_EXPORTS}/figures/lp_log"


/*****************************************************************************
* 0c. Provision data files which could not be shipped due to license restrictions
* 
* This file requires internet connection on first run
*
* Do not adjust
*****************************************************************************/
qui include "${DIR_PROJ}/src/00_utils/provision.do"


/*****************************************************************************
* 1. Preprocessing
*
* Preprocess raw data files to speed up subsequent analysis
* Coding rules:
* - Read only from DIR_DATA_RAW, DIR_DATA_PROCESSED
* - Write only to DIR_DATA_PROCESSED
* - Saved filenames should either be equal to name of do file or prefixed accordingly
* - If other preprocessed inputs required, flag in comments
*****************************************************************************/

/*
* Description: Linking table transforming CoW codes to ISO 3166-1 alpha-3 (handcoded)
* Runtime: <0h0m01s
*/
qui include "${DIR_SRC_PROCESS}/isolinks.do"

/*
* Description: Prepare mortality data
* Runtime: <0h0m01s
*/
qui include "${DIR_SRC_PROCESS}/mortality.do"

/*
* Description: Prepare CoW contiguity data
* Requirements: isolinks
* Runtime: <0h0m01s
*/
*qui include "${DIR_SRC_PROCESS}/contiguity.do"

/*
* Description: Prepare country-pair distances
* Runtime: <0h00m01s
*/
*qui include "${DIR_SRC_PROCESS}/distances.do"

/*
* Description: Construct deflator to convert current to 2015 constant USD
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_PROCESS}/deflator.do"

/*
* Description: Prepare military expenditures
* Requirements: isolinks, deflator
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_PROCESS}/milex.do"

/*
* Description: Prepare trade data, generate Table B.1 (${DIR_DATA_EXPORTS}/tables/trade_gravity_body.tex, ${DIR_DATA_EXPORTS}/tables/trade_gravity_footer.tex)
* Requirements: deflator
* Runtime: ~0h03m00s
*/
qui include "${DIR_SRC_PROCESS}/trade_gravity.do"

/*
* Description: Prepare trade data
* Requirements: trade_gravity
* Runtime: <0h00m10s
*/
qui include "${DIR_SRC_PROCESS}/trade_national.do"

/*
* Description: Prepare population data
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_PROCESS}/pop.do"

/*
* Description: Prepare territorial changes data (binary indicator and population impacts)
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_PROCESS}/territory.do"

/*
* Description: Prepare world population data
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_PROCESS}/pop_world.do"
/*
* Description: Prepare capital stock and TFP data
* Requirements: pop
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_PROCESS}/ltp.do"

/*
* Description: Prepare macro data
* Requirements: pop, ltp, trade_national, milex
* Runtime: <0h00m15s
*/
qui include "${DIR_SRC_PROCESS}/macro.do"

/*
* Description: Prepare interstate data
* Requirements: isolinks
* Runtime: ~0h01m00s
*/
qui include "${DIR_SRC_PROCESS}/interstate.do"

/*
* Description: Prepare intrastate and extrastate data
* Requirements: isolinks
* Runtime: <0h00m05s
*/
qui include "${DIR_SRC_PROCESS}/intrastate.do"

/*
* Description: Prepare country-specific geopolitical risk index (GPR)
* Requirements: isolinks
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_PROCESS}/gprc.do"

/*
* Description: Prepare war site shock measures and cross-border propagation through trade
* Requirements: isolinks
* Runtime: <0h00m30s
*/
qui include "${DIR_SRC_PROCESS}/sites.do"


/*****************************************************************************
* 2. Exports
*
* Generates exports (tables, figures, numbers).
*
* Coding rules:
*	- Read only from DIR_DATA_RAW and DIR_DATA_PROCESSED
*	- Write only to DIR_SRC_EXPORTS
*	- Saved filenames should either be equal to name of do file, prefixed accordingly, or be in a folder
*****************************************************************************/

/*
* Figure 9: ${DIR_DATA_EXPORTS}/figures/descriptives/anticipation/interstate_cycle.pdf, ${DIR_DATA_EXPORTS}/figures/descriptives/anticipation/intrastate_cycle.pdf
* Figure O-D.1: ${DIR_DATA_EXPORTS}/figures/descriptives/anticipation/interstate_macro.pdf
* Figure O-D.2: ${DIR_DATA_EXPORTS}/figures/descriptives/anticipation/intrastate_macro.pdf
* Figure O-D.3: ${DIR_DATA_EXPORTS}/figures/descriptives/anticipation/interstate_trade.pdf, ${DIR_DATA_EXPORTS}/figures/descriptives/anticipation/intrastate_trade.pdf
* Runtime: ~0h03m30s
*/
qui include "${DIR_SRC_EXPORTS}/figures/descriptives/anticipation.do"

/*
* Figure 1: ${DIR_DATA_EXPORTS}/figures/descriptives/distribution.pdf
* Text numbers: Relative frequencies of becoming site or adjacent to war: ${DIR_DATA_EXPORTS}/figures/descriptives/distribution_numbers_paper.txt
* Runtime: <0h00m02s
*/
qui include "${DIR_SRC_EXPORTS}/figures/descriptives/distribution.do"

/*
* Figure A.1: ${DIR_DATA_EXPORTS}/figures/descriptives/worldmap.pdf
* Runtime: <0h00m02s
*/
qui include "${DIR_SRC_EXPORTS}/figures/descriptives/worldmap.do"

/*
* Figure 2(a): ${DIR_DATA_EXPORTS}/figures/fig_warshock_interstate_barplot_0.1.pdf
* Figure 2(b): ${DIR_DATA_EXPORTS}/figures/fig_warshock_other_barplot_0.1.pdf
* Figure 3(a): ${DIR_DATA_EXPORTS}/figures/fig_warshock_histogram_log10_combined.pdf
* Text numbers: Kolmogorov-Smirnov Test (footnote 12): ${DIR_DATA_EXPORTS}/figures/kolmogorov_smirnov.txt
* Runtime: <0h00m02s
*/
qui rcall clear  // Clear rcall cache
qui rcall: rm(list = ls(all = TRUE)); gc() // Start fresh R session
local casualties_plotsR_path = subinstr("${DIR_SRC_EXPORTS}", "\", "/", .) + "/figures/casualties_plots.R" // robust cross-platform (MacOS, Linux, Windows)
rcall: source("`casualties_plotsR_path'")figures/descriptives/kolmogorov_smirnov.txt

/*
* Figure 3(b): ${DIR_DATA_EXPORTS}/figures/casdestr.pdf
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_EXPORTS}/figures/descriptives/casdestr.do"

/*
* Figure 4: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure 5: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure 6: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure 8: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.1.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[territory]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.1.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[territory]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.1.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[territory]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[territory]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.1.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[territory]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.2.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww1]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.2.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww1]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.2.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww1]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[exww1]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.2.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww1]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.2.5: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww2]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.2.6: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww2]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.2.7: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww2]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[exww2]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.2.8: ${DIR_DATA_EXPORTS}/figures/lp/panel[exww2]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.3.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[prekb]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.3.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[prekb]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.3.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[prekb]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[prekb]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.3.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[prekb]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.3.5: ${DIR_DATA_EXPORTS}/figures/lp/panel[postkb]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.3.6: ${DIR_DATA_EXPORTS}/figures/lp/panel[postkb]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.3.7: ${DIR_DATA_EXPORTS}/figures/lp/panel[postkb]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[postkb]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.3.8: ${DIR_DATA_EXPORTS}/figures/lp/panel[postkb]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.4.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[balanced]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.4.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[balanced]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.4.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[balanced]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[balanced]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.4.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[balanced]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.5.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[min1000cas]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.5.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[min1000cas]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.5.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[min1000cas]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[min1000cas]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.5.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[min1000cas]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.6.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[intrastate]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.6.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[intrastate]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.6.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[intrastate]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[intrastate]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-B.6.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[intrastate]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.7.1 top:    ${DIR_DATA_EXPORTS}/figures/lp/panel[region_americas]_layout[cycle_small]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.7.1 middle: ${DIR_DATA_EXPORTS}/figures/lp/panel[region_europe]_layout[cycle_small]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-B.7.1 bottom: ${DIR_DATA_EXPORTS}/figures/lp/panel[region_asia]_layout[cycle_small]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.1.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[destroles]_estopt[standard]_h[8].pdf
* Figure O-C.1.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[desttrd]_estopt[standard]_h[8].pdf
* Figure O-C.1.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[destroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[desttrd]_estopt[standard]_h[8].pdf
* Figure O-C.1.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[society]_spec[destroles]_estopt[standard]_h[8].pdf
* Figure O-C.2.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[casroles]_estopt[standard]_h[16].pdf
* Figure O-C.2.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[castrd]_estopt[standard]_h[16].pdf
* Figure O-C.2.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[casroles]_estopt[standard]_h[16].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[castrd]_estopt[standard]_h[16].pdf
* Figure O-C.2.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[society]_spec[casroles]_estopt[standard]_h[16].pdf
* Figure O-C.3.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[castrd_bell]_estopt[standard]_h[8].pdf
* Figure O-C.3.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[castrd_bell]_estopt[standard]_h[8].pdf
* Figure O-C.4.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[altstart]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.4.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[altstart]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.4.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[altstart]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[altstart]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.4.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[altstart]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.5.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[casroles_nl]_estopt[standard]_h[8].pdf
* Figure O-C.5.5: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[castrd_nl]_estopt[standard]_h[8].pdf
* Figure O-C.5.6: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[casroles_nl]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[castrd_nl]_estopt[standard]_h[8].pdf
* Figure O-C.5.7: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[society]_spec[casroles_nl]_estopt[standard]_h[8].pdf
* Figure O-C.6.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[nationalism]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.6.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[nationalism]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.6.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[nationalism]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[nationalism]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.6.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[nationalism]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.7.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[openness]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.7.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[openness]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.7.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[openness]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[openness]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.7.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[openness]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.8.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[winsorized]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.8.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[winsorized]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.8.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[winsorized]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[winsorized]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.8.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[winsorized]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.9.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro_hp]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.9.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro_hp]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.10.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro_pl]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.10.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro_pl]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.11.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[short]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.11.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[short]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.11.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[short]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[short]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.11.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[short]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.12.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[long]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.12.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[long]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.12.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[long]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[long]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.12.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[long]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.13.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[macro]_spec[casprox]_estopt[standard]_h[8].pdf
* Figure O-C.13.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[all]_layout[trade]_spec[casprox]_estopt[standard]_h[8].pdf
* Figure O-C.14.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[milstrength]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.14.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[milstrength]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.14.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[milstrength]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[milstrength]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.14.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[milstrength]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.15.1: ${DIR_DATA_EXPORTS}/figures/lp/panel[causality]_layout[macro]_spec[casroles]_estopt[standard]_h[8].pdf
* Figure O-C.15.2: ${DIR_DATA_EXPORTS}/figures/lp/panel[causality]_layout[macro]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.15.3: ${DIR_DATA_EXPORTS}/figures/lp/panel[causality]_layout[trade]_spec[casroles]_estopt[standard]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/lp/panel[causality]_layout[trade]_spec[castrd]_estopt[standard]_h[8].pdf
* Figure O-C.15.4: ${DIR_DATA_EXPORTS}/figures/lp/panel[causality]_layout[society]_spec[casroles]_estopt[standard]_h[8].pdf
* Runtime: ~0h55m00s
*/
qui include "${DIR_SRC_EXPORTS}/figures/lp.do"

/*
* Figure 7: ${DIR_DATA_EXPORTS}/figures/heterogeneity/panel[interstate]_spec[wl_sites]_h[8].pdf, ${DIR_DATA_EXPORTS}/figures/heterogeneity/panel[interstate]_spec[wl_bell]_h[8].pdf
* Runtime: <0h01m30s
*/
qui include "${DIR_SRC_EXPORTS}/figures/lp_heterogeneity.do"

/*
* Figure O-C.5.1: ${DIR_DATA_EXPORTS}/figures/nonlinear_cas_casroles_site.pdf
* Figure O-C.5.2: ${DIR_DATA_EXPORTS}/figures/nonlinear_cas_castrd_exposed.pdf
* Runtime: <0h02m30s
*/
qui include "${DIR_SRC_EXPORTS}/figures/nonlinear_cas.do"

/*
* Figure O-C.5.3: ${DIR_DATA_EXPORTS}/figures/figures/nonlinear_trd.pdf
* Runtime: ~0h00m30s
*/
qui include "${DIR_SRC_EXPORTS}/figures/nonlinear_trade.do"

/*
* Text numers: Battle numbers and correlation with GPT-4 mentioned in paper
* Runtime: ~0h01m00s
*/
qui include "${DIR_SRC_EXPORTS}/tables/descriptives/battlenumbers.do"

/*
* Online Appendix O-E (Casus Belli)
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_EXPORTS}/tables/descriptives/casusbelli.do"

/*
* Table 2: ${DIR_DATA_EXPORTS}/tables/descriptives/reasons.tex
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_EXPORTS}/tables/descriptives/reasons.do"

/*
* Table 1: ${DIR_DATA_EXPORTS}/tables/descriptives/sample_interstate.tex, ${DIR_DATA_EXPORTS}/tables/descriptives/sample_intrastate.tex, ${DIR_DATA_EXPORTS}/tables/descriptives/sample_all.tex
* Runtime: <0h02m00s
*/
qui include "${DIR_SRC_EXPORTS}/tables/descriptives/sample.do"

/*
* Table A.1 top:    ${DIR_DATA_EXPORTS}/tables/descriptives/sample_extensive_macro.tex
* Table A.1 middle: ${DIR_DATA_EXPORTS}/tables/descriptives/sample_extensive_trade.tex
* Table A.1 bottom: ${DIR_DATA_EXPORTS}/tables/descriptives/sample_extensive_society.tex
* Runtime: ~0h02m30s
*/
qui include "${DIR_SRC_EXPORTS}/tables/descriptives/sample_extensive.do"

/*
* Table O-A.1: ${DIR_DATA_EXPORTS}/tables/descriptives/sites.tex
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_EXPORTS}/tables/descriptives/sites.do"

/*
* Table O-A.2: ${DIR_DATA_EXPORTS}/tables/descriptives/sites_gpt.tex
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_EXPORTS}/tables/descriptives/sites_gpt.do"

/*
* Table O-A.4: ${DIR_DATA_EXPORTS}/tables/strengthgrowth.tex
* Runtime: <0h01m00s
*/
qui include "${DIR_SRC_EXPORTS}/tables/strengthgrowth.do"

/*
* Table O-A.5: ${DIR_DATA_EXPORTS}/tables/attackers.tex
* Runtime: <0h00m01s
*/
qui include "${DIR_SRC_EXPORTS}/tables/attackers.do"

/*
* More numbers mentioned in paper
* Runtime: <0h02m00s
*/
qui include "${DIR_SRC_EXPORTS}/textnumbers.do"

/*
* Table O-F-1: ${DIR_DATA_EXPORTS}/tables/predictability/tbl_gdp_inter.tex
* Table O-F-2: ${DIR_DATA_EXPORTS}/tables/predictability/tbl_infl_inter.tex
* Table O-F-3: ${DIR_DATA_EXPORTS}/tables/predictability/tbl_both_inter.tex
* Table O-F-4: ${DIR_DATA_EXPORTS}/tables/predictability/tbl_gdp_other.tex
* Table O-F-5: ${DIR_DATA_EXPORTS}/tables/predictability/tbl_infl_other.tex
* Table O-F-6: ${DIR_DATA_EXPORTS}/tables/predictability/tbl_both_other.tex
* Table 3: ${DIR_DATA_EXPORTS}/tables/predictability/tbl_predictability.tex
* Notes:
* - predictability.R is the main script that should be best run directly with R.
* - For convenience we run the R script within Stata using rcall.
* - Stata's console cuts off some wide tables; the generated tex files, however, contain the full width tables.
* Runtime: <0h00m30s
*/
qui rcall clear  // Clear rcall cache
qui rcall: rm(list = ls(all = TRUE)); gc() // Start fresh R session
local predictabilityR_path = subinstr("${DIR_SRC_EXPORTS}", "\", "/", .) + "/tables/predictability.R" // robust cross-platform (MacOS, Linux, Windows)
rcall: source("`predictabilityR_path'")


/*****************************************************************************
* 3. Housekeeping
*****************************************************************************/
display "Finished main.do at: " c(current_date) + " " + c(current_time)