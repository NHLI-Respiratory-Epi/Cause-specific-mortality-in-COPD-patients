
***************************************************
*Testing ICD10 positions

use ${final}cohort_with_causes_of_death, clear

*cause vs cause1
gen cause_vs_cause1=1 if icd10==cause1 & ons_death==1
recode cause_vs_cause1 .=0 if icd10!=cause1 & ons_death==1
tab cause_vs_cause1
*45.7% of ICD10 codes for cause are the same as cause 1

*cause vs cause2
gen cause_vs_cause2=1 if icd10==cause2 & cause_vs_cause1==0 & ons_death==1
recode cause_vs_cause2 .=0 if icd10!=cause2 & cause_vs_cause1==0 & ons_death==1
tab cause_vs_cause2
*28.5% of ICD10 codes for cause are the same as cause 2

*cause vs cause3
gen cause_vs_cause3=1 if icd10==cause3 & cause_vs_cause1==0 & cause_vs_cause2==0 & ons_death==1
recode cause_vs_cause3 .=0 if icd10!=cause3 & cause_vs_cause1==0 & cause_vs_cause2==0 & ons_death==1
*8.6% of ICD10 codes for cause are the same as cause 3
*17.2% of ICD10 codes for cause are not the same as the top 3 causes


rename icd10 icd10_second_position 

rename cause3 icd10
drop resp cvd digestive endocrine neoplasm mental copd copd_resp non_copd_resp other

*merge in icd10 codelists: respiratory, circulatory, digestive
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

merge m:1 icd10 using ${code}icd10_copd
keep if _m==3 | _m==1
drop _m
gen copd2=copd if copd==1 & ons_dod==endid & ons_death==1
recode copd2 .=0
drop copd
rename copd2 copd


gen other=1 if ons_death==1 & mental==0 & resp==0 & cvd==0 & endocrine==0 & digestive==0 & neoplasm==0 & ons_dod==endid
recode other .=0


gen copd_resp=1 if copd==1
recode copd_resp .=0
gen non_copd_resp=1 if resp==1 & copd_resp==0
recode non_copd_resp .=0



gen cause_of_death4=1 if copd_resp==1
replace cause_of_death4=2  if non_copd_resp==1
replace cause_of_death4=3 if cvd==1
replace cause_of_death4=4 if neoplasm==1
replace cause_of_death4=5 if digestive==1
replace cause_of_death4=6 if mental==1
replace cause_of_death4=7 if endocrine==1
replace cause_of_death4=8 if other==1
label define lab5 1"copd" 2"respiratory (non-copd)" 3"cvd" 4"neoplasm" 5"digestive" 6"mental" 7"endocrine" 8"other"
label values cause_of_death4 lab5
recode cause_of_death4 .=0


tab cause_of_death cause_of_death4 if cause_vs_cause3==0




