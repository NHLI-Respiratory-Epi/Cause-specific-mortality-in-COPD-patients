*For ATS abstract
************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "E:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "E:\Raw_cohorts\GSK_mortality\final_data_files\"

*******************************************************************************
 import delimited "E:\Raw_cohorts\21_000566\Results\Aurum_linked\death_patient_21_000566.txt", stringcols(1) clear 
save ${data}ons_death, replace

use ${final}base_cohort_hes_smok_1_year_pre_consultation_before, clear
merge 1:1 patid using ${data}ons_death
keep if _m==3 | _m==1
drop _m

gen ons_dod=date(dod, "DMY")
format ons_dod %td
drop dod

replace ons_dod=. if ons_dod>endid+7
replace endid=ons_dod if endid==cprd_ddate & cprd_ddate!=. & ons_dod!=.

gen ons_death=1 if ons_dod==endid
recode ons_death .=0
tab ons_death 

// 

/* ons_death |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    241,765       71.16       71.16
          1 |     97,981       28.84      100.00
------------+-----------------------------------
      Total |    339,746      100.00

*/

*cause vs cause1
bro patid cause cause1
gen cause_vs_cause1=1 if cause==cause1 & ons_death==1
recode cause_vs_cause1 .=0 if cause!=cause1 & ons_death==1
tab cause_vs_cause1
*45.7% of ICD10 codes for cause are the same as cause 1

*cause vs cause2
gen cause_vs_cause2=1 if cause==cause2 & cause_vs_cause1==0 & ons_death==1
recode cause_vs_cause2 .=0 if cause!=cause2 & cause_vs_cause1==0 & ons_death==1
tab cause_vs_cause2
*28.5% of ICD10 codes for cause are the same as cause 2

*cause vs cause3
gen cause_vs_cause3=1 if cause==cause3 & cause_vs_cause1==0 & cause_vs_cause2==0 & ons_death==1
recode cause_vs_cause3 .=0 if cause!=cause3 & cause_vs_cause1==0 & cause_vs_cause2==0 & ons_death==1
*8.6% of ICD10 codes for cause are the same as cause 3
*17.2% of ICD10 codes for cause are not the same as the top 3 causes


*top 10 causes of death
modes cause, nmodes(10)

*merge in icd10 codelists: respiratory, circulatory, digestive
rename cause icd10
merge m:1 icd10 using ${code}icd10_respiratory
keep if _m==3 | _m==1
drop _m
gen resp2=resp if resp==1 & ons_dod==endid & ons_death==1
recode resp2 .=0
drop resp
rename resp2 resp

merge m:1 icd10 using ${code}icd10_circulatory 
keep if _m==3 | _m==1
drop _m
gen cvd2=cvd if cvd==1 & ons_dod==endid & ons_death==1
recode cvd2 .=0
drop cvd
rename cvd2 cvd

merge m:1 icd10 using ${code}icd10_digestive
keep if _m==3 | _m==1
drop _m
gen digestive2=digestive if digestive==1 & ons_dod==endid & ons_death==1
recode digestive2 .=0
drop digestive
rename digestive2 digestive

merge m:1 icd10 using ${code}icd10_endocrine
keep if _m==3 | _m==1
drop _m
gen endocrine2=endocrine if endocrine==1 & ons_dod==endid & ons_death==1
recode endocrine2 .=0
drop endocrine
rename endocrine2 endocrine

merge m:1 icd10 using ${code}icd10_neoplasm
keep if _m==3 | _m==1
drop _m
gen neoplasm2=neoplasm if neoplasm==1 & ons_dod==endid & ons_death==1
recode neoplasm2 .=0
drop neoplasm
rename neoplasm2 neoplasm

merge m:1 icd10 using ${code}icd10_mental
keep if _m==3 | _m==1
drop _m
gen mental2=mental if mental==1 & ons_dod==endid & ons_death==1
recode mental2 .=0
drop mental
rename mental2 mental

***
*Generate a variable for second position 
gen second=1 if 

save ${final}cohort_with_causes_of_death, replace

*create a COPD-specific respiratory variable
merge m:1 icd10 using ${code}icd10_copd
keep if _m==3 | _m==1
drop _m
gen copd2=copd if copd==1 & ons_dod==endid & ons_death==1
recode copd2 .=0
drop copd
rename copd2 copd

gen copd_resp=1 if copd==1
recode copd_resp .=0

gen non_copd_resp=1 if resp==1 & copd_resp==0
recode non_copd_resp .=0
save ${final}cohort_with_causes_of_death, replace

*create an other variable
gen other=1 if ons_death==1 & mental==0 & resp==0 & cvd==0 & endocrine==0 & digestive==0 & neoplasm==0 & ons_dod==endid
recode other .=0


merge 1:1 patid using ${data}gold
drop _m
save ${final}cohort_with_causes_of_death, replace

*merge in covariates: MI, HF, stroke, hyptertension, diabetes, BMI, depression, anxiety, GORD, lung cancer, asthma 
merge 1:1 patid using ${data}mi_ever
drop _m
merge 1:1 patid using ${data}hf_ever
drop _m
merge 1:1 patid using ${data}stroke_ever
drop _m
merge 1:1 patid using ${data}hypertension_ever
drop _m
merge 1:1 patid using ${data}diabetes_ever
drop _m
merge 1:1 patid using ${data}bmi_5_years
drop _m
merge 1:1 patid using ${data}depression_ever 
drop _m
merge 1:1 patid using ${data}anxiety_ever
drop _m
merge 1:1 patid using ${data}gord_ever
drop _m
merge 1:1 patid using ${data}lung_cancer_ever
drop _m
merge 1:1 patid using ${data}asthma_ever
drop _m
save ${final}cohort_with_causes_of_death, replace

******************************************
*exposures that dont require HES linkage =GOLD & emphysema, chronic bronch
merge 1:1 patid using ${data}emphysema
keep if _m==3 | _m==1
drop _m
recode emphysema .=0
merge 1:1 patid using ${data}chronic_bronch
keep if _m==3 | _m==1
drop _m
recode chronic_bronch .=0

gen cause_of_death=1 if copd_resp==1
replace cause_of_death=2  if non_copd_resp==1
replace cause_of_death=3 if cvd==1
replace cause_of_death=4 if neoplasm==1
replace cause_of_death=5 if digestive==1
replace cause_of_death=6 if mental==1
replace cause_of_death=7 if endocrine==1
replace cause_of_death=8 if other==1
label define lab2 1"copd" 2"respiratory (non-copd)" 3"cvd" 4"neoplasm" 5"digestive" 6"mental" 7"endocrine" 8"other"
label values cause_of_death lab2
recode cause_of_death .=0
save ${final}cohort_with_causes_of_death, replace

use ${final}cohort_with_causes_of_death, clear
foreach var of varlist mi hf stroke depression anxiety gord lung_cancer hypertension diabetes asthma {
	recode `var' .=0
}
save ${final}cohort_with_causes_of_death, replace

	

*Mortality rates
gen pdays=endid-startid
replace pdays=pdays/365.25
replace pdays=. if pdays<=0

*COPD
ci means copd_resp , poisson exposure(pdays)
ci means cvd, poisson exposure(pdays)
ci means non_copd_resp, poisson exposure(pdays)
ci means neoplasm, poisson exposure(pdays)
ci means digestive, poisson exposure(pdays)
ci means mental, poisson exposure(pdays)
ci means endocrine, poisson exposure(pdays)
ci means other, poisson exposure(pdays)
ci means ons_death, poisson exposure(pdays)



tab gold cause_of_death, row
ci means ons_death if gold==1 , poisson exposure(pdays)
ci means ons_death if gold==2 , poisson exposure(pdays)
ci means ons_death if gold==3 , poisson exposure(pdays)
ci means ons_death if gold==4 , poisson exposure(pdays)




logistic ons_death i.gold
logistic ons_death gold age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma

logistic copd_resp i.gold
logistic copd_resp i.gold age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma



logistic cvd i.gold
logistic cvd i.gold age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma

*
gen copd_type=1 if emphysema==1
replace copd_type=2 if emphysema==0 & chronic_bronch==1
tab copd_type, miss
label define lab23 1"emphysema" 2"chronic bronch"
label values copd_type lab23

tab copd_type ons_death, row
tab copd_type cause_of_death, row

logistic copd_resp copd_type 
logistic cvd copd_type 







