clear all
macro drop _all

************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "E:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "E:\Raw_cohorts\GSK_mortality\final_data_files\"

global hes "E:\Raw_cohorts\HES_19\Results\Aurum_linked\"

global do "E:\Raw_cohorts\GSK_mortality\do_files\"
********************************************************************************

**********************************************************************
* STEP 1 - Find any Rx for our ABx and OCS
**********************************************************************
* these aren't definitions on their own, but we'll use them to construct other definitions later
use ${data}Copd_meds_all, clear
keep if groups==13 | groups==11
keep patid issuedate dosageid quantity duration quantunitid groups
gen ocs=1 if groups==11
recode ocs .=0
gen abx=1 if groups==13
recode abx .=0
drop groups
save ${data}ocs_abx_final, replace
gen eventdate=issuedate
format eventdate %td
drop issuedate
save ${data}ocs_abx_final, replace


* save a file containing patids and eventdates for any OCS / ABx Rx
preserve
keep patid eventdate
save ${data}any_ocs_abx, replace 
restore


* now find those which are both ABx and OCS and for 5-14 days
	* need NDDs at this point, if any missing and textid>100000 need to request these from CPRD and merge these in now
merge m:1 dosageid using ${code}common_dosages 
keep if _m==3 | _m==1
drop _m

	
keep patid eventdate ocs abx quantity daily_dose

gen duration = quantity/daily_dose 
tab duration

drop quantity daily_dose 

drop if duration <5
drop if duration >14


preserve
keep if abx==1
tempfile abx
keep patid eventdate abx
duplicates drop
save `abx'
restore

keep if ocs==1
merge m:1 patid eventdate using `abx'
keep if _m==3
drop _m
gen abx_ocs5_14=1
keep patid eventdate abx_ocs5_14
duplicates drop
save ${data}ocs_abx_duration5_14, replace

**********************************************************************
* STEP 2 - Find symptoms
**********************************************************************
	* these aren't definitions on their own, but we'll use them to construct other definitions later
use ${data}Observation_exposure_all, clear

preserve
keep if  breathless==1 
keep patid obsdate breathless
duplicates drop
gen eventdate=obsdate
format eventdate %td
drop obsdate
save ${data}breathless, replace
restore

preserve
keep if cough==1 
keep patid obsdate cough
duplicates drop
gen eventdate=obsdate
format eventdate %td
drop obsdate
save ${data}cough, replace
restore

preserve
keep if sputum==1 
keep patid obsdate sputum
duplicates drop
gen eventdate=obsdate
format eventdate %td
drop obsdate
save ${data}sputum, replace
restore

* make a file which is patids and eventdates for 2/3 of cough, sputum or breathlessness
use ${data}breathless, clear
merge 1:1 patid eventdate using ${data}sputum
drop _merge
merge 1:1 patid eventdate using ${data}cough
drop _merge

recode sputum .=0
recode cough .=0
recode breathless .=0

gen nsymps= sputum + cough + breathless
keep if nsymps==2 | nsymps==3

keep patid eventdate
duplicates drop
gen symps=1
save ${data}symptoms_2_3, replace

use ${data}any_ocs_abx, clear

merge m:1 patid eventdate using ${data}symptoms_2_3
gen symp_abx_ocs=1 if _m==3
drop _merge

keep patid eventdate symp_abx_ocs
duplicates drop

save ${data}symp_abx_ocs, replace

**********************************************************************
* STEP 3 - Now find events
**********************************************************************
use ${data}Observation_exposure_all, clear
keep if lrti==1 | aecopd==1
keep patid obsdate lrti aecopd
rename obsdate eventdate
duplicates drop
recode lrti .=0
recode aecopd .=0
save ${data}lrti_aecopd_all, replace
gen aecopd_event=1 if lrti==1 | aecopd==1
keep patid aecopd_event eventdate
duplicates drop


* merge in step 1 ABx and OCS Rx for 5-14 days on same day

merge 1:m patid eventdate using ${data}ocs_abx_duration5_14
replace aecopd_event=1 if _m==3
drop _merge

* add in step 2 Symptom definition (2/3 symptoms) and either ABx or OCS on same day

append using ${data}symp_abx_ocs
sort patid eventdate
replace aecopd_event=1 if symp_abx_ocs==1
save ${data}all_possible_aecopd_events_gp, replace



****************************************************************************
* STEP 4 get rid of events which are within 14 days of another event
****************************************************************************
keep if aecopd_event==1
keep patid eventdate aecopd_event
duplicates drop

sort patid eventdate
gen datelastobs=.

* for each patient, copy over eventdate from last observation (_n-1 observation) into datelastobs
sort patid eventdate
by patid: replace datelastobs=eventdate[_n-1]
format datelastobs %td

gen duration=eventdate-datelastobs

* kick out patients with recurrent events <15 days since last event
drop if duration <15
drop duration datelastobs

save ${data}all_possible_aecopd_events_gp, replace

**************************************************************************************
*STEP 5 Remove events that were recorded on an annual review
******************************************************************
forvalues f=1/84 {   
		local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

		use ${extract}Observation_`c', clear
	*merge with cohort
		merge m:1 patid using ${final}base_cohort_hes_smok
		keep if _m==3
		drop _m

		merge m:1 medcodeid using ${code}annual_review
		keep if _m==3
		drop _m
		save ${data}Observation_annual_review_`c', replace
		}

use ${data}Observation_annual_review_001, clear
forvalues f=2/84{
		local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */
		append using ${data}Observation_annual_review_`c'
		}
save ${data}Observation_annual_review_all, replace
keep patid obsdate 
duplicates drop 
gen annual_review=1
rename obsdate eventdate
save ${data}annual_review, replace


use ${data}all_possible_aecopd_events_gp, clear
merge 1:1 patid eventdate using ${data}annual_review 
gen annual_review_date=1 if _m==3
keep if _m==3 | _m==1
drop _m
drop if annual_review_date==1
drop annual_review annual_review_date
sort patid eventdate

save ${data}all_possible_aecopd_events_gp_after_ar, replace

**********************************
*STEP 6 Find HES events
**********************************
import delimited ${hes}hes_episodes_21_000566.txt , stringcols(1 3) clear 
save ${hes}HES_episodes, replace


**** insheet the HES data and just keep records for aecopd hosp and for those included in the study
import delimited  ${hes}hes_diagnosis_epi_21_000566.txt, stringcols(1 3) clear 

merge m:1 patid using ${final}base_cohort_hes_smok
keep if _m==3 
drop _m

save ${hes}hes_aecopd, replace

use ${hes}hes_aecopd, clear

* need to change this to where ever you put the "create_spells" programme
do ${do}create_spells

gen aecopd_diag1=.
gen aecopd_diagany=. // this would have to be j44.1 or j44.0 in any position or J44.9 in first

* current definition - j44.0 or j44.1 in any position, or j44.9 in first position
replace aecopd_diag1=1 if icd01=="J44.1" | icd01=="J44.0" | icd01=="J44.9" 

forvalues i=1/20	{
	
	replace aecopd_diagany=1 if icd0`i'== "J44.1" | icd0`i'=="J44.0" | icd0`i'== "J20" | icd0`i'=="J22"
	replace aecopd_diagany=1 if icd01=="J44.9"

} /* end of forvalues i=1/20 */

recode aecopd_diag1 (.=0) 
recode aecopd_diagany (.=0)

tab aecopd_diag1 aecopd_diagany

gen hes_event=1 if aecopd_diag1==1 | aecopd_diagany==1

* keep patids and spell numbers and merge these back into the HES file
preserve 
keep if hes_event==1
keep patid spell
duplicates drop

tempfile aecopd
save `aecopd'
restore

merge m:1 patid spell using `aecopd'
replace hes_event=1 if _m==3
drop _m

keep if hes_event==1

keep patid admidate hes_event 
duplicates drop

count
codebook patid

gen eventdate=admidate
format eventdate %td
drop admidate

save ${data}hosp_aecopd, replace

*********************************************
*STEP 7 merge GP and HES events together
*********************************************
use ${data}all_possible_aecopd_events_gp_after_ar, clear
merge 1:m patid eventdate using ${data}hosp_aecopd
drop _m
save ${data}all_aecopd, replace 

merge m:1 patid using ${final}base_cohort_hes_smok
keep if _m==3 
drop _m 

keep patid startid eventdate aecopd_event hes_event 
rename aecopd_event gp_aecopd
gen any_aecopd=1 if gp_aecopd==1 
replace any_aecopd=1 if hes_event==1 
codebook patid if any_aecopd==1

save ${data}any_aecopd, replace

recode gp_aecopd (.=0)
rename hes_event hes_aecopd
recode hes_aecopd (.=0)


recode gp_aecopd (1=0) if hes_aecopd==1 
*recode hes_aecopd (1=0) if ons_aecopd==1

order patid startid eventdate gp_aecopd hes_aecopd any_aecopd

sort patid eventdate
gen datelastobs=.
by patid: replace datelastobs=eventdate[_n-1]
format datelastobs %td

gen duration=eventdate-datelastobs

by patid: replace hes_aecopd=1 if gp_aecopd==1 & duration[_n+1]<15 & hes_aecopd[_n+1]==1

drop  if duration<15

save ${data}aecopd_final




















