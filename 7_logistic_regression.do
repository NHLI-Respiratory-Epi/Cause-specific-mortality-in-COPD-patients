*Logistic regression for cause of death
************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "E:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "E:\Raw_cohorts\GSK_mortality\final_data_files\"

*******************************************************************
use ${final}complete_cohort, clear

**********************************************
*Exposure 1: FEV1 % predicted
***********************************************
*Step 1: all-cause
logistic ons_death i.gold
logistic ons_death i.gold age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any

*interaction with age
logistic ons_death i.gold##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.age_group 
logistic ons_death i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==1
logistic ons_death i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==2
logistic ons_death i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==3
logistic ons_death i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==4
logistic ons_death i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==5

*interaction with gender
logistic ons_death i.gold##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.gender 
logistic ons_death i.gold  age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if gender==1
logistic ons_death i.gold  age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if gender==2

*interaction with smoking status
logistic ons_death i.gold##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.smokstatus 
logistic ons_death i.gold  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if smokstatus==1
logistic ons_death i.gold  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if smokstatus==2



*STEP 2: COPD related********************************************
logistic copd_resp i.gold
logistic copd_resp i.gold age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any

*Interaction with age 
logistic copd_resp i.gold##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.age_group
logistic copd_resp i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==1
logistic copd_resp i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==2
logistic copd_resp i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==3
logistic copd_resp i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==4
logistic copd_resp i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==5

*interaction with gender
logistic copd_resp i.gold##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.gender 
logistic copd_resp i.gold  age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if gender==1
logistic copd_resp i.gold  age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if gender==2

*interaction with smoking status
logistic copd_resp i.gold##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.smokstatus 
logistic copd_resp i.gold  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if smokstatus==1
logistic copd_resp i.gold  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if smokstatus==2

*STEP 3: CVD mortality***********************************
logistic cvd i.gold
logistic cvd i.gold age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any

*Interaction with age 
logistic cvd i.gold##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.age_group
logistic cvd i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==1
logistic cvd i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==2
logistic cvd i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==3
logistic cvd i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==4
logistic cvd i.gold smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any if age_group==5

*interaction with gender
logistic cvd i.gold##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.gender // no interaction

*interaction with smoking status
logistic cvd i.gold##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma aecopd_any
testparm i.gold#i.smokstatus // no interaction 


*************************************************************
*Exposure 2: GOLD ABCD
*Nb: havent adjusted for AECOPD here because of colinearility
************************************************************
*Step 1: all-cause
logistic ons_death i.gold_abcd
logistic ons_death i.gold_abcd age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma 

*interaction with age
logistic ons_death i.gold_abcd##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.age_group 
logistic ons_death i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==1
logistic ons_death i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==2
logistic ons_death i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==3
logistic ons_death i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==4
logistic ons_death i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==5

*interaction with gender
logistic ons_death i.gold_abcd##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.gender  // no interaction with gender

*interaction with smoking status
logistic ons_death i.gold_abcd##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.smokstatus 
logistic ons_death i.gold_abcd  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if smokstatus==1
logistic ons_death i.gold_abcd  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if smokstatus==2


*STEP 2: COPD related********************************************
logistic copd_resp i.gold_abcd
logistic copd_resp i.gold_abcd age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma

*Interaction with age 
logistic copd_resp i.gold_abcd##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.age_group
logistic copd_resp i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==1
logistic copd_resp i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==2
logistic copd_resp i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==3
logistic copd_resp i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==4
logistic copd_resp i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==5

*interaction with gender
logistic copd_resp i.gold_abcd##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.gender // no interaction

*interaction with smoking status
logistic copd_resp i.gold_abcd##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.smokstatus 
logistic copd_resp i.gold_abcd  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if smokstatus==1
logistic copd_resp i.gold_abcd  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if smokstatus==2

*STEP 3: CVD mortality***********************************
logistic cvd i.gold_abcd
logistic cvd i.gold_abcd age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma

*Interaction with age 
logistic cvd i.gold_abcd##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.age_group
logistic cvd i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==1
logistic cvd i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==2
logistic cvd i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==3
logistic cvd i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==4
logistic cvd i.gold_abcd smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma if age_group==5

*interaction with gender
logistic cvd i.gold_abcd##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.gender // no interaction

*interaction with smoking status
logistic cvd i.gold_abcd##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma
testparm i.gold_abcd#i.smokstatus // no interaction 



*************************************************************
*Exposure 3: AECOPD any vs none
************************************************************
*Step 1: all-cause
logistic ons_death i.aecopd_any
logistic ons_death i.aecopd_any age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*interaction with age
logistic ons_death i.aecopd_any##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.age_group 

logistic ons_death i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic ons_death i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic ons_death i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic ons_death i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic ons_death i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic ons_death i.aecopd_any##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.gender  
logistic ons_death i.aecopd_any age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if gender==1
logistic ons_death i.aecopd_any age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if gender==2


*interaction with smoking status
logistic ons_death i.aecopd_any##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.smokstatus 
logistic ons_death i.aecopd_any  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if smokstatus==1
logistic ons_death i.aecopd_any  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma  i.gold if smokstatus==2


*STEP 2: COPD related********************************************
logistic copd_resp i.aecopd_any
logistic copd_resp i.aecopd_any age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*Interaction with age 
logistic copd_resp i.aecopd_any##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.age_group
logistic copd_resp i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic copd_resp i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic copd_resp i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic copd_resp i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic copd_resp i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic copd_resp i.aecopd_any##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.gender // no interaction

*interaction with smoking status
logistic copd_resp i.aecopd_any##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.smokstatus 
logistic copd_resp i.aecopd_any  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if smokstatus==1
logistic copd_resp i.aecopd_any  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if smokstatus==2

*STEP 3: CVD mortality***********************************
logistic cvd i.aecopd_any
logistic cvd i.aecopd_any age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*Interaction with age 
logistic cvd i.aecopd_any##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.age_group
logistic cvd i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic cvd i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic cvd i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic cvd i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic cvd i.aecopd_any smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic cvd i.aecopd_any##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.gender // no interaction

*interaction with smoking status
logistic cvd i.aecopd_any##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_any#i.smokstatus // no interaction 



*************************************************************
*Exposure 4: AECOPD frequency
************************************************************
*Step 1: all-cause
logistic ons_death i.aecopd_freq
logistic ons_death i.aecopd_freq age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*interaction with age
logistic ons_death i.aecopd_freq##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.age_group 

logistic ons_death i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic ons_death i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic ons_death i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic ons_death i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic ons_death i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic ons_death i.aecopd_freq##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.gender  
logistic ons_death i.aecopd_freq age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if gender==1
logistic ons_death i.aecopd_freq age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if gender==2


*interaction with smoking status
logistic ons_death i.aecopd_freq##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.smokstatus 
logistic ons_death i.aecopd_freq  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if smokstatus==1
logistic ons_death i.aecopd_freq  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma  i.gold if smokstatus==2


*STEP 2: COPD related********************************************
logistic copd_resp i.aecopd_freq
logistic copd_resp i.aecopd_freq age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*Interaction with age 
logistic copd_resp i.aecopd_freq##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.age_group
logistic copd_resp i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic copd_resp i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic copd_resp i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic copd_resp i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic copd_resp i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic copd_resp i.aecopd_freq##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.gender // no interaction

*interaction with smoking status
logistic copd_resp i.aecopd_freq##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.smokstatus 
logistic copd_resp i.aecopd_freq  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if smokstatus==1
logistic copd_resp i.aecopd_freq  age gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if smokstatus==2

*STEP 3: CVD mortality***********************************
logistic cvd i.aecopd_freq
logistic cvd i.aecopd_freq age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*Interaction with age 
logistic cvd i.aecopd_freq##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.age_group
logistic cvd i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic cvd i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic cvd i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic cvd i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic cvd i.aecopd_freq smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic cvd i.aecopd_freq##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.gender // no interaction

*interaction with smoking status
logistic cvd i.aecopd_freq##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_freq#i.smokstatus // no interaction 



*************************************************************
*Exposure 5: AECOPD severity
************************************************************
*Step 1: all-cause
recode aecopd_mod_sev 1=2 0=1 .=0
label define lab_mod 0"none" 1"moderate" 2"severe"
label values aecopd_mod_sev lab_mod

logistic ons_death i.aecopd_mod_sev
logistic ons_death i.aecopd_mod_sev age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*interaction with age
logistic ons_death i.aecopd_mod_sev##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.age_group 

logistic ons_death i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic ons_death i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic ons_death i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic ons_death i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic ons_death i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic ons_death i.aecopd_mod_sev##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.gender  // no interaction

*interaction with smoking status
logistic ons_death i.aecopd_mod_sev##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.smokstatus // no interaction


*STEP 2: COPD related********************************************
logistic copd_resp i.aecopd_mod_sev
logistic copd_resp i.aecopd_mod_sev age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*Interaction with age 
logistic copd_resp i.aecopd_mod_sev##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.age_group
logistic copd_resp i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic copd_resp i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic copd_resp i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic copd_resp i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic copd_resp i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic copd_resp i.aecopd_mod_sev##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.gender // no interaction

*interaction with smoking status
logistic copd_resp i.aecopd_mod_sev##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.smokstatus // no interaction

*STEP 3: CVD mortality***********************************
logistic cvd i.aecopd_mod_sev
logistic cvd i.aecopd_mod_sev age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold

*Interaction with age 
logistic cvd i.aecopd_mod_sev##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.age_group
logistic cvd i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==1
logistic cvd i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==2
logistic cvd i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==3
logistic cvd i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==4
logistic cvd i.aecopd_mod_sev smokstatus gender    mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold if age_group==5

*interaction with gender
logistic cvd i.aecopd_mod_sev##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.gender // no interaction

*interaction with smoking status
logistic cvd i.aecopd_mod_sev##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold
testparm i.aecopd_mod_sev#i.smokstatus // no interaction 




*************************************************************
*Exposure 6: COPD type (bronch vs emph)
************************************************************
*Step 1: all-cause
logistic ons_death i.bronch_emph
logistic ons_death i.bronch_emph age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any

*interaction with age
logistic ons_death i.bronch_emph##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.age_group // no interaction


*interaction with gender
logistic ons_death i.bronch_emph##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.gender  
logistic ons_death i.bronch_emph age  smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any if gender==1 
logistic ons_death i.bronch_emph age  smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold  aecopd_any if gender==2


*interaction with smoking status
logistic ons_death i.bronch_emph##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.smokstatus 
logistic ons_death i.bronch_emph age  gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold  aecopd_any if smokstatus==1 
logistic ons_death i.bronch_emph age  gender mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any if smokstatus==2


*STEP 2: COPD related********************************************
logistic copd_resp i.bronch_emph
logistic copd_resp i.bronch_emph age gender smokstatus
logistic copd_resp i.bronch_emph age gender smokstatus mi hf stroke depression anxiety gord lung_cancer
logistic copd_resp i.bronch_emph age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes 
logistic copd_resp i.bronch_emph age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes i.gold aecopd_any 
logistic copd_resp i.bronch_emph age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes i.gold aecopd_any asthma
*driven by asthma

*Interaction with age 
logistic copd_resp i.bronch_emph##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.age_group // no interaction

*interaction with gender
logistic copd_resp i.bronch_emph##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.gender 
logistic copd_resp i.bronch_emph age  smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold  aecopd_any if gender==1 
logistic copd_resp i.bronch_emph age  smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any if gender==2


*interaction with smoking status
logistic copd_resp i.bronch_emph##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.smokstatus // no interaction

*STEP 3: CVD mortality***********************************
logistic cvd i.bronch_emph
logistic cvd i.bronch_emph age gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
recode gold .=0


*Interaction with age 
logistic cvd i.bronch_emph##i.age_group gender smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.age_group //no interaction

*interaction with gender
logistic cvd i.bronch_emph##i.gender age smokstatus mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.gender // no interaction

*interaction with smoking status
logistic cvd i.bronch_emph##i.smokstatus gender age  mi hf stroke depression anxiety gord lung_cancer i.bmi_group hypertension diabetes asthma i.gold aecopd_any
testparm i.bronch_emph#i.smokstatus // no interaction 


