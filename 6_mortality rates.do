*Generate mortality rates
************************************************************************
clear all
set more off, perm
macro drop _all

global extract "E:\Raw_cohorts\CPRD_Aurum_2021\"

global data "E:\Raw_cohorts\GSK_mortality\working_data\"

global code "E:\Raw_cohorts\GSK_mortality\code_lists\"

global final "E:\Raw_cohorts\GSK_mortality\final_data_files\"

log using "E:\Raw_cohorts\GSK_mortality\logs\mortality rates.log"
*******************************************************************

use ${final}complete_cohort, clear

gen bronch_emph=1 if emphysema==1
recode bronch_emph .=0 if chronic_bronch==1
tab bronch_emph
label define lab1 0"chronic bronch" 1"emphysema"
label values bronch_emph lab1

gen copd_death=1 if cause_of_death==1
recode copd_death .=0

gen cvd_death=1 if cause_of_death==3
recode cvd_death .=0

gen pdays=endid-startid
replace pdays=pdays/365.25
replace pdays=. if pdays<=0


*crude and adjusted mortality rates 
foreach var of varlist ons_death copd_death cvd_death {

*general mortality rates
ci means `var', poisson exposure(pdays) 
poisson `var' i.age_group gender i.smokstatus, exp(pdays) irr
margins ,predict(ir)


*mortality rates by aecopd (any vs none)
ci means `var' if aecopd_any==0 , poisson exposure(pdays)
ci means `var' if aecopd_any==1 , poisson exposure(pdays)
poisson cvd_death  i.age_group gender i.smokstatus i.aecopd_any, exp(pdays) irr
margins aecopd_any ,predict(ir)

*mortality rates by aecopd (frequent vs infrequent)
ci means `var' if aecopd_freq==1 , poisson exposure(pdays)
ci means `var' if aecopd_freq==2 , poisson exposure(pdays)
poisson `var'  i.age_group gender i.smokstatus i.aecopd_freq, exp(pdays) irr
margins aecopd_freq ,predict(ir)

*mortality rates by aecopd (mod vs sev)
ci means `var' if aecopd_mod_sev==1 , poisson exposure(pdays)
ci means `var' if aecopd_mod_sev==2 , poisson exposure(pdays)
poisson `var'  i.age_group gender i.smokstatus i.aecopd_mod_sev, exp(pdays) irr
margins aecopd_mod_sev ,predict(ir)

*mortality rates by bronch/emph
ci means `var' if bronch_emph==0 , poisson exposure(pdays)
ci means `var' if bronch_emph==1 , poisson exposure(pdays)
poisson `var'  i.age_group gender i.smokstatus i.bronch_emph, exp(pdays) irr
margins bronch_emph ,predict(ir)

*mortality rates by gold abcd
ci means `var' if gold_abcd==1 , poisson exposure(pdays)
ci means `var' if gold_abcd==2 , poisson exposure(pdays)
ci means `var' if gold_abcd==3 , poisson exposure(pdays)
ci means `var' if gold_abcd==4 , poisson exposure(pdays)
poisson `var'  i.age_group gender i.smokstatus i.gold_abcd, exp(pdays) irr
margins gold_abcd ,predict(ir)

*mortality rates by gold
ci means `var' if gold==1 , poisson exposure(pdays)
ci means `var' if gold==2 , poisson exposure(pdays)
ci means `var' if gold==3 , poisson exposure(pdays)
ci means `var' if gold==4 , poisson exposure(pdays)
poisson `var'  i.age_group gender i.smokstatus i.gold, exp(pdays) irr
margins gold ,predict(ir)

}
