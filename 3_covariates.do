*Generating covariates
************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "E:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "E:\Raw_cohorts\GSK_mortality\final_data_files\"

log using "E:\Raw_cohorts\GSK_mortality\logs\Covariates.log", replace
********************************************************************************

*merging covariate code lists: BMI, depression, anxiety, GORD, lung cancer, MI, HF, stroke, asthma, hypertension, diabetes, cholesterol, IMD, MRC (in exposure do file), GOLD (in exposure do file), GOLD ABCD (in exposure do file), medication (merged already in exposure do file)


*BMI, depression, anxiety, GORD, lung cancer, asthma

    forvalues f=1/84 {   
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

use ${extract}Observation_`c', clear
*merge with cohort
merge m:1 patid using ${final}base_cohort_hes_smok_1_year_pre_consultation_before
keep if _m==3
drop _m

merge m:1 medcodeid using ${code}bmi_final
drop _m
merge m:1 medcodeid using ${code}depression_final
drop _m
merge m:1 medcodeid using ${code}anxiety_final
drop _m
merge m:1 medcodeid using ${code}gord_final
drop _m
merge m:1 medcodeid using ${code}lung_cancer_final
drop _m
merge m:1 medcodeid using ${code}Asthma_AM
drop _m


*Keep these observations only
keep if bmi==1 | depression==1 | anxiety==1 | gord==1 | lung_cancer==1 | asthma==1 

save ${data}Observation_covariate_list_1_`c', replace
}

use ${data}Observation_covariate_list_1_001, clear
    forvalues f=2/84 {   
local c=string(`f',"%03.0f") 
append using ${data}Observation_covariate_list_1_`c'
	}
save ${data}Observation_covariate_list_1_all, replace

**************


*MI, HF, stroke, hyptertension, diabetes using medcodeids

    forvalues f=1/84 {   
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

use ${extract}Observation_`c', clear
*merge with cohort
merge m:1 patid using ${final}base_cohort_hes_smok_1_year_pre_consultation_before
keep if _m==3
drop _m

merge m:1 medcodeid using ${code}mi_Laura_and_final
drop _m
merge m:1 medcodeid using ${code}hf_Laura_and_final
drop _m
merge m:1 medcodeid using ${code}stroke_Laura_and_final
drop _m
merge m:1 medcodeid using ${code}hypertension_Laura
drop _m
merge m:1 medcodeid using ${code}diabetes_Laura
drop _m

*Keep these observations only
keep if mi==1 | hf==1 | stroke==1 | hypertension==1 | diabetes==1 

save ${data}Observation_covariate_lisst_2_`c', replace
}

use ${data}Observation_covariate_lisst_2_001, clear
    forvalues f=2/84 {   
local c=string(`f',"%03.0f") 
append using ${data}Observation_covariate_lisst_2_`c'
	}
save ${data}Observation_covariate_list_2_all, replace

*********************************************************
*list 1 BMI, depression, anxiety, GORD, lung cancer, asthma 
********************************************************
use ${data}Observation_covariate_list_1_all, clear

preserve
keep if obsdate<startid
keep if depression==1
keep patid depression
duplicates drop
save ${data}depression_ever, replace
restore 

preserve
keep if obsdate<startid
keep if anxiety==1
keep patid anxiety
duplicates drop
save ${data}anxiety_ever, replace
restore 

preserve
keep if obsdate<startid
keep if gord==1
keep patid gord
duplicates drop
save ${data}gord_ever, replace
restore 

preserve
keep if obsdate<startid
keep if lung_cancer==1
keep patid lung_cancer
duplicates drop
save ${data}lung_cancer_ever, replace
restore 

preserve
keep if obsdate<startid
keep if asthma==1
keep patid asthma
duplicates drop
save ${data}asthma_ever, replace
restore 

************************************************
*list 2 MI, HF, stroke, hyptertension, diabetes 
***************************************************
use ${data}Observation_covariate_list_2_all, clear

preserve
keep if obsdate<startid
keep if mi!=.
keep patid 
gen mi=1
duplicates drop
save ${data}mi_ever, replace
restore 

preserve
keep if obsdate<startid
keep if hf!=.
keep patid 
gen hf=1
duplicates drop
save ${data}hf_ever, replace
restore 

preserve
keep if obsdate<startid
keep if stroke!=.
keep patid 
gen stroke=1
duplicates drop
save ${data}stroke_ever, replace
restore 

preserve
keep if obsdate<startid
keep if hypertension!=.
keep patid 
gen hypertension=1
duplicates drop
save ${data}hypertension_ever, replace
restore 

preserve
keep if obsdate<startid
keep if diabetes!=.
keep patid 
gen diabetes=1
duplicates drop
save ${data}diabetes_ever, replace
restore 




*************************************************
*BMI-last 5 years
*************************************************

use ${data}Observation_covariate_list_1_all, clear
keep if bmi==1
keep patid obsdate bmi startid value 
duplicates drop 
gen date_five=startid-(365.25*5)
format date_five %td

keep if obsdate>=date_five & obsdate<startid
sort patid obsdate
keep if value!=.

by patid: gen litn=_n
by patid: gen bign=_N
keep if litn==bign

gen bmi_group=.
replace bmi_group=1 if value<18.5
replace bmi_group=2 if value>=18.5 & value<25
replace bmi_group=3 if value>=25 & value<30
replace bmi_group=4 if value>=30

label define lab_bmi 1"Underweight" 2"Normal" 3"Overweight" 4"Obese"
label values bmi_group lab_bmi

keep patid  bmi_group
save ${data}bmi_5_years, replace

/*
**********************************************
*Asthma-3 years before 2 years prior to startid
****************************************************
{
use ${covar}covar_list_1_all, clear
keep if asthma==1
keep patid asthma obsdate startid
duplicates drop

gen five_years=startid-(365.25*5)
format five_years %td
gen two_years=startid-(365.25*2)
format two_years %td

keep if obsdate>=five_years & obsdate<=two_years
keep patid asthma
duplicates drop
save ${covar}asthma_5_years_2_years, replace

use ${cohort}base_cohort_hes_smok_covar, clear
merge 1:1 patid using ${covar}asthma_5_years_2_years
keep if _m==3 | _m==1
drop _m
save ${cohort}base_cohort_hes_smok_covar, replace
}













