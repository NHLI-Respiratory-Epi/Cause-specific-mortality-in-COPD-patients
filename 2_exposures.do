*Merging exposure variables with observation files
************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "D:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "D:\Raw_cohorts\GSK_mortality\final_data_files\"

********************************************************************************

*merging exposure code lists. 

    forvalues f=1/84 {   
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

use ${extract}Observation_`c', clear
*merge with cohort
merge m:1 patid using ${final}base_cohort_hes_smok
keep if _m==3
drop _m

merge m:1 medcodeid using ${code}mrc_breathless_final
drop _m
merge m:1 medcodeid using ${code}cough_final
drop _m
merge m:1 medcodeid using ${code}sputum_final
drop _m
merge m:1 medcodeid using ${code}aecopd_final
drop _m
merge m:1 medcodeid using ${code}lrti_final
drop _m
merge m:1 medcodeid using ${code}spirometry_final
drop _m
merge m:1 medcodeid using ${code}height_final
drop _m
merge m:1 medcodeid using ${code}annual_review_copd_aurum_final
drop _m
merge m:1 medcodeid using ${code}emphysema_final
drop _m
merge m:1 medcodeid using ${code}chronic_bronch_final
drop _m



*Keep these observations only
keep if breathless==1 | cough==1 | sputum==1 | aecopd==1 | lrti==1 | fev1==1 | fev1_pred==1 | fvc==1 | fvc_pred==1 | generalspirom==1 | height==1 | annual_review==1 | emphysema==1 | chronic_bronch==1 

save ${data}Observation_exposure_`c', replace
}

use ${data}Observation_exposure_001, clear
    forvalues f=1/84 {   
local c=string(`f',"%03.0f") 
append using ${data}Observation_exposure_`c'
	}
save ${data}Observation_exposure_all, replace

**************



*merging exposure code lists. 

    forvalues f=1/84 {   
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

use ${extract}DrugIssue_`c', clear
*merge with cohort
merge m:1 patid using ${final}base_cohort_hes_smok
keep if _m==3
drop _m

merge m:1 prodcodeid using ${code}COPD_meds_final
keep if _m==3
drop _m

save ${data}DrugIssue_copdmeds_`c', replace
}

use ${data}DrugIssue_copdmeds_001, clear
forvalues f=2/84{
	local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of 	preceeding zeros */
	append using ${data}DrugIssue_copdmeds_`c'
}
save ${data}Copd_meds_all, replace

************************************
*Chonic bronchitis and emphysema
**************************************
use ${data}Observation_exposure_all, clear
keep if obsdate!=.
save ${data}Observation_exposure_all, replace

use ${data}copd_aurum_patid_001, clear
forvalues f=2/84{
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */
append using ${data}copd_aurum_patid_`c'
}
merge m:1 medcodeid using ${code}COPD_A
keep if copd_emphysema=="1" | copd_bronchitis==1
keep patid obsdate copd_emphysema copd_bronchitis
duplicates drop
save ${data}emphysema_bronch_from_copd_codes, replace
merge m:1 patid using ${final}base_cohort_hes_smok_1_year_pre_consultation_before
keep if _m==3
drop _m
save ${data}emphysema_bronch_from_copd_codes, replace


*emphysema
use ${data}Observation_exposure_all, clear
keep if emphysema==1
keep if obsdate<=startid
keep patid startid obsdate emphysema
sort patid obsdate
drop obsdate startid
duplicates drop 
*35,387 have emphysema
merge m:1 patid using ${final}base_cohort_hes_smok_1_year_pre_consultation_before
keep if _m==3
drop _m
keep  if emphysema==1
keep patid emphysema 
duplicates drop
save ${data}emphysema, replace

use ${data}emphysema_bronch_from_copd_codes, clear
keep if copd_emphysema=="1"
keep if obsdate<=startid
keep patid copd_emphysema
gen emphysema=1 
drop copd_emphysema
append using ${data}emphysema
duplicates drop
*all the copd ones were recorded as separate empysema codes too. So let's not worry with these. 
save ${data}emphysema, replace



*chronic bronchitis 
use ${data}Observation_exposure_all, clear
keep if chronic_bronch==1
keep if obsdate<=startid
keep patid startid obsdate chronic_bronch
sort patid obsdate
drop obsdate startid
duplicates drop 
*8,552 have chronic_bronch
save ${data}chronic_bronch, replace



**********************************
*FEV1 % predicted - GOLD 
*********************************
*height 
use ${data}Observation_exposure_all, clear
keep if height==1
keep patid obsdate numunitid value
sort patid obsdate 
merge m:1 patid using ${final}base_cohort_hes_smok_1_year_pre_consultation_before
keep if _m==3
drop _m
sort patid obsdate
by patid: gen litn=_n
by patid: gen bign=_N
keep if litn==bign
keep patid obsdate value numunitid 
*122=cm, 173=m,408=cm
keep if numunitid==122 | numunitid==173 | numunitid==408
replace value=value/100 if numunitid==122 | numunitid==408
keep patid value
rename value height
keep if height<3
save ${data}height_per_patient, replace

******************
*11/01/22- new gold code list
********************************

    forvalues f=1/84 {   
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

use ${extract}Observation_`c', clear
*merge with cohort
merge m:1 patid using ${final}base_cohort_hes_smok
keep if _m==3
drop _m

merge m:1 medcodeid using ${code}spirometry_test
keep if _m==3
drop _m


*Keep these observations only
keep if fev1==1 | fev1_percent_pred==1

save ${data}Observation_spirom_`c', replace
}

use ${data}Observation_spirom_001, clear
    forvalues f=1/84 {   
local c=string(`f',"%03.0f") 
append using ${data}Observation_spirom_`c'
	}
save ${data}Observation_spirom_all, replace


*FEV1
use ${data}Observation_spirom_all, clear
tab numunitid if fev1!=.
*1=%, 160=litres, 166=litres, 167=litres, 200=ml, 315=ml, 839=litres, 928=litres, 334=L 
keep if fev1==1 | fev1_percent_pred==1 
gen fev1_1=value if fev1==1 
gen fev1_pred_1=value if fev1_percent_pred==1
gen unit="L" if numunitid==160 | numunitid==167 | numunitid==839 | numunitid==928 | numunit==166 | numunit==334
replace unit="ml" if numunitid==200 | numunitid==315
replace unit="%" if numunitid==1 
drop fev1 fev1_percent_pred
rename fev1_1 fev1
rename fev1_pred_1 fev1_pred
keep if fev1!=. | fev1_pred!=. 
keep patid fev1 fev1_pred obsdate unit
duplicates drop
save ${data}spirom_for_gold_new, replace

use ${data}spirom_for_gold_new, clear
merge m:1 patid using ${final}base_cohort_hes_smok_1_year_pre_consultation_before
keep if _m==3
drop _m
keep patid obsdate fev1 fev1_pred unit gender age startid

*keep FEV1 % predicted or FEV1 that is 2 years prior to startid or 3 months after
gen year=startid-(365.25*2)
format year %td

keep if obsdate<=startid+90 & obsdate>=year

merge m:1 patid using ${data}height_per_patient
keep if _m==3 | _m==1
drop _m


*transform ml to litres
replace unit="L" if fev1<=7
replace fev1=fev1/1000 if unit=="ml"

gen pred_fev1_calc=((4.3*height) - (0.0290*age)-2.490) if gender==1
replace pred_fev1_calc=((3.95*height) - (0.025*age)-2.6) if gender==2

gen percent_fev_calc=(fev1/pred_fev1)*100 if unit!="%"
sum percent_fev_calc, det

replace percent_fev_calc=. if percent_fev_calc>151 
replace percent_fev_calc=.  if percent_fev_calc<8 

replace percent_fev_calc=fev1_pred if percent_fev_calc==. 

replace percent_fev_calc=. if percent_fev_calc>151 
replace percent_fev_calc=.  if percent_fev_calc<8 

keep if percent_fev_calc!=.

keep patid obsdate percent_fev_calc
sort patid obsdate
by patid: gen litn=_n
by patid: gen bign=_N
keep if litn==bign
keep patid percent_fev
duplicates drop
save ${data}fev1_percent_predicted_baseline_new, replace

gen gold=1 if percent_fev>=80  & percent_fev!=.
replace gold=2 if percent_fev>=50 & percent_fev<80  & percent_fev!=.
replace gold=3 if percent_fev>=30 & percent_fev<50  & percent_fev!=.
replace gold=4 if percent_fev<30 & percent_fev!=.
label define lab_gold 1"mild" 2"moderate" 3"severe" 4"very severe"
label values gold lab_gold
keep patid gold
save ${data}gold_new, replace


*******************************
*aecopd frequency year prior
*******************************
use ${data}aecopd_final, clear 
keep if eventdate>=(startid-365.25) & eventdate<startid

sort patid eventdate
by patid: gen any_gp=sum(gp_aecopd)
by patid: gen any_hes=sum(hes_aecopd)
by patid: egen max_gp=max(any_gp)
by patid: egen max_hes=max(any_hes)

keep patid max_gp max_hes
duplicates drop
save ${data}aecopd_one_line

use ${final}base_cohort_hes_smok_1_year_pre_consultation_before, clear
merge 1:1 patid using ${data}aecopd_one_line
drop _m

recode max_gp .=0
recode max_hes .=0
gen max_any=max_gp + max_hes

*frequent vs infrequent (2+ or less than 2)
*0
gen aecopd_freq=0 if max_any==0
*1
replace aecopd_freq=1 if max_any==1
*2+
replace aecopd_freq=2 if max_any>=2 

/*aecopd_freq |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    230,249       60.09       60.09
          1 |     94,819       24.75       84.84
          2 |     58,075       15.16      100.00
------------+-----------------------------------
      Total |    383,143      100.00

*/

*non-aecopd vs aecopd
gen aecopd_any=0 if max_any==0 
recode aecopd_any .=1
/*
 aecopd_any |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    230,249       60.09       60.09
          1 |    152,894       39.91      100.00
------------+-----------------------------------
      Total |    383,143      100.00
*/

*moderate vs severe
gen aecopd_mod_sev=0 if max_gp>=1
recode aecopd_mod_sev .=1 if max_hes>=1
/*

aecopd_mod_ |
        sev |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    123,419       80.72       80.72
          1 |     29,475       19.28      100.00
------------+-----------------------------------
      Total |    152,894      100.00
*/


keep patid aecopd_freq aecopd_any aecopd_mod_sev
save ${data}aecopd_exposure, replace

*******************************************************
*GOLD ABCD
**********************************************************
*find mrc first 
use ${data}Observation_exposure_all, clear
keep if mrc==1
keep patid startid mrc mrc_value obsdate
duplicates drop
keep if obsdate>=(startid-(365.25*5)) & obsdate<=startid
sort patid obsdate
*keep latest value
by patid: gen litn=_n
by patid: gen bign=_N
keep if litn==bign
keep patid mrc_value
save ${data}mrc_exposure

*merge with aecopd file
use ${final}base_cohort_hes_smok_1_year_pre_consultation_before, clear
merge 1:1 patid using ${data}aecopd_exposure
drop _m

merge 1:1 patid using ${data}mrc_exposure
keep if _m==3 | _m==1
drop _m

keep patid mrc_value aecopd_freq aecopd_mod_sev

gen gold_abcd=.
replace gold_abcd=1 if aecopd_freq==0  & mrc_value<2 & mrc_value!=.
replace gold_abcd=1 if aecopd_freq==1 & mrc_value<2 & aecopd_mod_sev!=1 & mrc_value!=.

replace gold_abcd=2 if aecopd_freq==0 & mrc_value>=2 & mrc_value!=.
replace gold_abcd=2 if aecopd_freq==1 & mrc_value>=2 & aecopd_mod_sev!=1 & mrc_value!=.

replace gold_abcd=3 if aecopd_freq==2 & mrc_value<2 & mrc_value!=.
replace gold_abcd=3 if aecopd_freq==1 & mrc_value<2 & aecopd_mod_sev==1 & mrc_value!=.

replace gold_abcd=4 if aecopd_freq==2 & mrc_value>=2  & mrc_value!=.
replace gold_abcd=4 if aecopd_freq==1 & mrc_value>=2 & aecopd_mod_sev==1 & mrc_value!=.


keep patid gold_abcd mrc_value
save ${data}gold_abcd_exposure, replace

*Let's see how well CAT is recorded 
    forvalues f=1/84 {   
local c=string(`f',"%03.0f") /*converting number f to 3 digit string so we get the correct number of preceeding zeros */

use ${extract}Observation_`c', clear
*merge with cohort
merge m:1 patid using ${final}base_cohort_hes_smok
keep if _m==3
drop _m

merge m:1 medcodeid using ${code}cat_score_gsk
keep if _m==3
drop _m

save ${data}cat_score_`c', replace
}

use ${data}cat_score_001, clear
    forvalues f=2/84 {   
local c=string(`f',"%03.0f") 
append using ${data}cat_score_`c'
	}
save ${data}cat_score_all, replace

keep patid startid obsdate value cat cat_type
duplicates drop
keep if cat==1
keep if obsdate>=(startid-(365.25*5)) & obsdate<=startid

*keep cat_all score and save separately 
keep if cat_type=="catall"
sort patid obsdate
keep patid value cat_type
duplicates drop
*keep latest value
by patid: gen litn=_n
by patid: gen bign=_N
keep if litn==bign
keep patid value
rename value cat_value
save ${data}catall_exposure, replace

*keep if cat is scored separately and save separately 
use ${data}cat_score_all, clear
keep patid startid obsdate value cat cat_type
duplicates drop
keep if cat==1
keep if obsdate>=(startid-(365.25*5)) & obsdate<=startid
gen cat1=value if cat_type=="cat1"
gen cat2=value if cat_type=="cat2"
gen cat3=value if cat_type=="cat3"
gen cat4=value if cat_type=="cat4"
gen cat5=value if cat_type=="cat5"
gen cat6=value if cat_type=="cat6"
gen cat7=value if cat_type=="cat7"
gen cat8=value if cat_type=="cat8"
foreach var of varlist cat1-cat8 {
    preserve
    keep patid obsdate `var'
	keep if `var'!=.
	sort patid obsdate
	by patid: gen litn=_n
	by patid: gen bign=_N
	keep if litn==bign
	keep patid `var'
	duplicates drop
	save ${data}cat_`var'_exposure, replace
	restore
}

*keep unlablled cat values and save separately (this will be for those who dont have any of the other cat types)
use ${data}cat_score_all, clear
keep patid startid obsdate value cat cat_type
duplicates drop
keep if cat==1
keep if obsdate>=(startid-(365.25*5)) & obsdate<=startid
replace cat_type="." if cat_type!="cat1" & cat_type!="cat2" & cat_type!="cat3" & cat_type!="cat4" & cat_type!="cat5" & cat_type!="cat6" & cat_type!="cat7" & cat_type!="cat8" & cat_type!="catall"
keep if cat==1 & cat_type=="." & value!=.
sort patid obsdate
	by patid: gen litn=_n
	by patid: gen bign=_N
	keep if litn==bign
	keep patid value
	duplicates drop
	save ${data}cat_last_exposure, replace


*merge together 
use ${data}catall_exposure, clear
rename cat_value cat_all
merge 1:1 patid using ${data}cat_cat1_exposure
drop _m
merge 1:1 patid using ${data}cat_cat2_exposure
drop _m
merge 1:1 patid using ${data}cat_cat3_exposure
drop _m
merge 1:1 patid using ${data}cat_cat4_exposure
drop _m
merge 1:1 patid using ${data}cat_cat5_exposure
drop _m
merge 1:1 patid using ${data}cat_cat6_exposure
drop _m
merge 1:1 patid using ${data}cat_cat7_exposure
drop _m
merge 1:1 patid using ${data}cat_cat8_exposure
drop _m
merge 1:1 patid using ${data}cat_last_exposure
rename value last_option
drop _m

*gen calculate cat
gen cat_cal=cat1+cat2+cat3+cat4+cat5+cat6+cat7+cat8
drop cat1-cat8
gen cat_final=cat_all 
replace cat_final=cat_cal if cat_final==. & cat_cal!=.
replace cat_final=last_option if cat_final==. & last_option!=.
keep patid cat_final
duplicates drop
save ${data}cat_final_exposure, replace


	
*merge cat, mrc, aecopd and base cohort file
use ${final}base_cohort_hes_smok_1_year_pre_consultation_before, clear
merge 1:1 patid using ${data}aecopd_exposure
drop _m

merge 1:1 patid using ${data}mrc_exposure
keep if _m==3 | _m==1
drop _m

merge 1:1 patid using ${data}cat_final_exposure
keep if _m==3 | _m==1
drop _m

keep patid mrc_value aecopd_freq cat_final
codebook patid if cat_final!=. & mrc_value==.
*only 497 extra people have cat but not mrc


gen gold_abcd=.
*gold a=0/1 aecopd and mmrc 0-1 (mrc 1/2)
replace gold_abcd=1 if aecopd_freq==0 & mrc_value<=2 & mrc_value!=.
*gold b=0/1 aecopd and mmrc >=2 (mrc >=3)
replace gold_abcd=2 if aecopd_freq==0  & mrc_value>=3 & mrc_value!=.
*gold c=>=2 aecopd and mmrc 0-1 (mrc 1/2)
replace gold_abcd=3 if aecopd_freq==1 & mrc_value<=2 & mrc_value!=.
*gold d=>=2 aecopd and mmrc >=2 (mrc>=3)
replace gold_abcd=4 if aecopd_freq==1 & mrc_value>=3 & mrc_value!=.


*gold a=0/1 aecopd and cat<10
replace gold_abcd=1 if aecopd_freq==0 & cat_final<10 & cat_final!=. & gold_abcd==.
*gold b=0/1 aecopd and cat>=10
replace gold_abcd=2 if aecopd_freq==0  & cat_final>=10 & cat_final!=. & gold_abcd==.
*gold c=>=2 aecopd and <10
replace gold_abcd=3 if aecopd_freq==1 & cat_final<10 & cat_final!=. & gold_abcd==.
*gold d=>=2 aecopd and cat>=10
replace gold_abcd=4 if aecopd_freq==1 & cat_final>=10 & cat_final!=. & gold_abcd==.

keep patid gold_abcd
duplicates drop
save ${data}gold_abcd_exposure_with_cat, replace

*Nb: only used MRC score in final analysis.

************************
*AECOPD periods- stable vs not stable
***********************

use ${final}complete_cohort, clear

*all-cause mortality
keep if ons_death==1
keep patid endid ons_death copd_resp cvd
duplicates drop
save ${data}mid_way, replace

merge 1:m patid using ${data}aecopd_final
keep if _m==3 | _m==1
drop _m

keep if eventdate>=startid & eventdate<=endid

keep patid endid eventdate startid  ons_death copd_resp cvd

sort patid eventdate

by patid: gen litn=_n
by patid: gen bign=_N
keep if litn==bign 
drop litn bign

merge 1:1 patid using ${data}mid_way
drop _m

gen followup=eventdate+30
format followup %td

gen aecopd_death=1 if endid>=eventdate & endid<=followup
recode aecopd_death .=0

save ${data}aecopd_sens_analysis, replace


use ${final}complete_cohort, clear
keep patid gold cause_of_death
duplicates drop
merge 1:1 patid using ${data}aecopd_sens_analysis
keep if _m==3
drop _m

tab aecopd_death copd_resp, row
 
tab aecopd_death copd_resp if gold==1, row
tab aecopd_death copd_resp if gold==2, row
tab aecopd_death copd_resp if gold==3, row
tab aecopd_death copd_resp if gold==4, row

gen death_type=1 if copd_resp==1 
recode death_type .=2 if cvd==1
recode death_type .=3 if ons_death==1 & copd_resp==0 & cvd==0

tab aecopd_death death_type if gold==1, row
tab aecopd_death death_type if gold==2, row
tab aecopd_death death_type if gold==3, row
tab aecopd_death death_type if gold==4, row





