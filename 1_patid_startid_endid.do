*Base cohort for GSK study 
************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "E:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "E:\Raw_cohorts\GSK_mortality\final_data_files\"

log using "E:\Raw_cohorts\GSK_mortality\logs\patid_startid.log"
**********************************************************************************
*Use the patient_practice file and merge with obs files and COPD codelist to find people with COPD
	
forvalues f=1/84 {   // potentially 1/84
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

use ${extract}patient_practice, clear 
merge 1:m patid using ${extract}Observation_`c'
keep if _merge==3
drop _merge 

merge m:1 medcodeid using ${code}COPD_A
keep if _merge==3
drop _merge

save ${data}copd_aurum_patid_`c', replace
}



use ${data}copd_aurum_patid_001
forvalues f=2/84{
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */
append using ${data}copd_aurum_patid_`c'
}

drop Term OriginalReadCode CleansedReadCode SnomedCTConceptId SnomedCTDescriptionId Release

sort patid obsdate
keep if obsdate!=.
by patid: gen litn=_n
keep if litn==1
keep patid obsdate
duplicates drop
gen first_copd=obsdate

format first_copd %td
keep patid first_copd

*This file contains the date of FIRST COPD diagnosis
save ${data}first_copd_aurum, replace

******************************************************************
*1) Patid, startid, endid
********************************************************************
*use patient_practice file and merge with first COPD file just created
use ${extract}patient_practice, clear 
merge m:1 patid using ${data}first_copd_aurum
keep if _m==3
drop _m
*706,965 have COPD diagnosis

*make 40th birthday date 
gen date40=	date("01/07/"+string(yob+40), "DMY") 
format date40 %td


*change these to your study start and end dates - they are macros, so you need to run these lines and the startid/endid lines all at once.
local startdate = date("01/01/2010", "DMY") 
display %td (`startdate')
local enddate = date("01/01/2020", "DMY") 
display %td (`enddate')



* gen start and end dates for each patient
gen startid = max(regstartdate, date40, first_copd, `startdate')
gen endid = min(regenddate, lcd, cprd_ddate, `enddate')
format startid endid %td

codebook patid

bro if startid>=endid
drop if startid>=endid
codebook patid
*602,758

keep patid pracid gender dob yob regstartdate regenddate cprd_ddate lcd  first_copd date40 startid endid
save ${data}patid_startid_endid, replace


**********************************************************************
*2) HES linkage
*******************************************************************
*Use file with startid and endid already defined
use ${data}patid_startid_endid, clear 
merge 1:1 patid using ${extract}HES_elig
gen keep=1 if hes_e==1 & death_e==1 & lsoa_e==1 & _m==3
count if keep==1 
codebook patid if keep==1
keep if keep==1
drop _m

drop keep mh_e lsoa_e cr_e death_e hes_e linkdate
codebook patid
*502,249
save ${data}base_cohort_hes, replace 


*************************************************************************
*3) Smoking status
************************************************************************
forvalues i=1/84 {   // potentially 1/84
local c=string(`i',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */
use patid medcodeid obsdate using ${extract}Observation_`c', clear
merge m:1 patid using ${data}base_cohort_hes
keep if _m==3 
drop _m

merge m:1 medcodeid using ${code}smoking_final
rename _merge smokingdatamatched

gsort patid -smokingdatamatched obsdate
by patid: drop if smokingdatamatched!=3 & _n>1
replace obsdate=. if smokingdatamatched!=3

gen _distance = obsdate-startid
gen _priority = 1 if _distance>=-365 & _distance<=30
replace _priority = 2 if _distance>30 & _distance<=365
replace _priority = 3 if _distance<-365
replace _priority = 4 if _distance>365 & _distance<.
gen _absdistance = abs(_distance)
replace _priority = 5 if smokstatus==.

sort patid _priority _absdistance 

*Patients nearest status is non-smoker, but have history of smoking, recode to ex-smoker.
by patid: gen b4=1 if obsdate<=obsdate[1]
drop if b4==.
by patid: egen ever_smok=sum(smokstatus) 
by patid: replace smokstatus = 1 if ever_smok>0 & smokstatus==0

sort patid _priority _absdistance 
by patid: replace smokstatus = smokstatus[1] 
drop smokingdatamatched _distance _priority _absdistance   
by patid: keep if _n==1
label define lab_smok 0"Never" 1"Ex-smoker" 2"Current"
label values smokstatus lab_smok
keep patid smokstatus obsdate
keep if smokstatus!=. 
save ${data}smoking_`i', replace
}

use ${data}smoking_1, clear

forvalues i=2/84{
append using ${data}smoking_`i'
}
sort patid obsdate 

merge m:1 patid using ${data}base_cohort_hes
keep if _m==3 | _m==2
drop _m
keep patid smokstatus obsdate startid
sort patid obsdate 
tab smokstatus
keep if smokstatus!=. 
gen diff=startid-obsdate
replace diff=0 if diff==.

replace diff=diff*(-1) if diff<0
sort patid diff
by patid: gen litn=_n
keep if litn==1
drop diff litn obsdate
save ${data}Smoking , replace 

use ${data}base_cohort_hes, clear
merge 1:1 patid using ${data}Smoking 
keep if _m==3
drop _m
codebook patid 
*479,577
tab smokstatus
save ${final}base_cohort_hes_smok, replace

*************************************************************************
*4) with at least one year of CPRD registration before COPD diagnosis 
*************************************************************************
use ${final}base_cohort_hes_smok, clear

gen one_year=first_copd-365.25
format one_year %td
codebook patid if regstartdate<one_year
gen flag=1 if regstartdate<one_year
keep if flag==1
drop one_year flag
save  ${final}base_cohort_hes_smok_1_year_pre, replace



**************************************************************************
*5) with at least one year of pre-disease consultation in their CPRD history
*************************************************************************

forvalues i=1/22 {   // potentially 1/84
local c=string(`i',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */
use patid consdate  using ${extract}Consultation_`c', clear

merge m:1 patid using ${final}base_cohort_hes_smok_1_year_pre
keep if _m==3
drop _m

save ${data}Consultation_dates_pre_copd_`c', replace
}

use ${data}Consultation_dates_pre_copd_001, clear
forvalues i=1/22 {   // potentially 1/84
local c=string(`i',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */
append using ${data}Consultation_dates_pre_copd_`c'
}

gen flag=1 if consdate<first_copd
keep if flag==1
drop consdate flag
duplicates drop 
codebook patid 
*339,746
save ${final}base_cohort_hes_smok_1_year_pre_consultation_before, replace


***************************************************
*a few baseline characteristics

gen age=startid-dob
replace age=age/365.25
hist age 
sum age

gen age_group=1 if age<50
replace age_group=2 if age>=50 & age<60
replace age_group=3 if age>=60 & age<70
replace age_group=4 if age>=70 & age<80
replace age_group=5 if age>=80
label define lab_age 1"<50" 2"50-59" 3"60-69" 4"70-79" 5"80+"
label values age_group lab_age
tab gender
tab smokstatus

gen death=1 if cprd_ddate!=.
recode death .=0
tab death

save ${final}base_cohort_hes_smok_1_year_pre_consultation_before, replace

log close



