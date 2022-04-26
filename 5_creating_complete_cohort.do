*Creat final cohort with all exposures and covariates and mortality
************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "E:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "E:\Raw_cohorts\GSK_mortality\final_data_files\"

*******************************************************************************

use ${final}cohort_with_causes_of_death, clear

*this file already has GOLD 1-4 and chronic bronch/emphysema exposures and causes of death 

*merge in aecopd and gold a-d
merge 1:1 patid using ${data}aecopd_exposure
keep if _m==3
drop _m

merge 1:1 patid using ${data}gold_abcd_exposure_with_cat
keep if _m==3
drop _m

save ${final}complete_cohort, replace





