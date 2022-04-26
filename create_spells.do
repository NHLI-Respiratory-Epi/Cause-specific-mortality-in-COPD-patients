/*=========================================================================
DO FILE NAME:			aki2-createHESspells.doi

AUTHOR:					Kate Mansfield		
VERSION:				v1
DATE VERSION CREATED: 	15th Jan 2015

DATASETS USED: 	HES version 10 datasets:
					HES_diagnosis_epi	// diagnoses for HES episodes
					HES_episodes		// information about HES episodes
					HES_patient			// provides ethnicity from HES records
					HES_procedures_epi	// provides details of procedures (including as may contain dialysis codes)
					
				Patids of cases 
						
DESCRIPTION OF FILE:	Extracts data for a list of patids from HES data files
		Aim is for this file to work for both cases and controls
		Therefore need to declare the following global in the do-file that
			includes this file:
	global caseCntrl "cases"	// to include in filename of datasets created
		== "cases" if extract is for cases
		== "cntrl" if extract is for controls
	
	
	Have set section 3.3 to 0 so that hospitalisations are not merged together into spells - KJR 091115
	
	
*=========================================================================*/



/*******************************************************************************
#1 Create one record per episode in diagnosis file
*******************************************************************************/
* Expand diagnoses variables so that there is an icd code for each diagnositic order
* prepare data to collapse on epikey
* create variables for each diagnosis

forvalues x = 1/20  {
	generate icd0`x'=icd if d_order==`x'
}

* make each record represent an episode
collapse (firstnm) icd0*, by (patid epikey epistart epiend) //firstnm=first non-missing value




/*******************************************************************************
#2 Add in extra information from HES_episodes file
*******************************************************************************/
* duplicates report epikey patid // no duplicates on epikey and patid
merge m:1 patid epikey using "E:\Raw_cohorts\HES_19\Results\Aurum_linked\HES_episodes.dta"
keep if _m==3
drop _m


/*******************************************************************************
#3 Construct spells defined as 2 or less days between consecutive episodes
*******************************************************************************/
* 3.1 format dates
*-------------------------------------------------------------------------------
gen admidate2 = date(admidate, "DMY")
format admidate2 %td
drop admidate
rename admidate2 admidate 

gen epistart2 = date(epistart, "DMY")
format epistart2 %td
drop epistart
rename epistart2 epistart

gen epiend2 = date(epiend, "DMY")
format epiend2 %td
drop epiend
rename epiend2 epiend

gen discharged2 = date(discharged, "DMY")
format discharged2 %td
drop discharged
rename discharged2 discharged

order patid spno epikey admidate epistart epiend discharged


* 3.2 data consistency checking before creating spells
*-------------------------------------------------------------------------------
drop if epistart==. 		// no missing epistart dates

/*
assert epiend!=.		// cases: 137 missing epiend dates
count if epiend==. & discharged==.	// cases: 22 records with missing epiend and discharge dates
*/

* use discharge date if it exists and epiend date is missing
replace epiend=discharged if (epiend==. & discharged!=.)	// cases: 115 changes made

* count num of episodes with missing epiend and missing discharge date 
* where discharge method indicates that patient DIED (i.e. dismeth==4)
count if epiend==. & discharge==. & dismeth==4	// there no records where patient died and epiend + discharge dates missing

* pragmatic solution delete records where epiend is missing
drop if epiend==.	// 22 records deleted




* 3.3 Generate spells
*-------------------------------------------------------------------------------
* construct hospital inpatient spells defined using up to 0 days between 
* consecutive episode >> counts these 0 days between episodes as a failed discharge
sort patid epistart epiend	// sort into correct order prior to creating spells
gen CHEspell = _n
replace CHEspell = CHEspell[_n-1] if	///
	patid==patid[_n-1] &				///
	epistart <= epiend[_n-1] + 0
egen spell = group(CHEspell)
drop CHEspell

* label new var
label variable spell "spell: cont inpx stay, max 2days btwn consec epis: aki2-createHESspells.doi"





/*******************************************************************************
#4 Label variables
*******************************************************************************/
forvalues n = 1/20 {
	label variable icd0`n' "icd0`n': Position `n' icd diagnosis"
}
label variable admidate "admidate: date of admission"
label variable epistart "epistart: date of episode start"
label variable epiend "epiend: date of episode end"
label variable discharged "discharged: date of discharge"
label variable eorder "eorder: order of episode within a spell"
label variable epidur "epidur: duration of episode in days"
label variable epitype "epitype: type of episode (general, delivery, birth, psych, etc)"
label variable admimeth "admimeth: method of admission"
label variable admisorc "admisorc: source of admission"
label variable disdest "disdest: destination on discharge"
label variable dismeth "dismeth: method of discharge"
label variable mainspef "mainspef: speciality under which consultant is contracted"
label variable pconsult "pconsult: consultant code"
label variable intmanig "intmanig: intended management"
label variable classpat "classpat: px classification: 1=ordinary; 2=day case; etc."
label variable firstreg "firstreg: first regular day or night admission"
label variable tretspef "tretspef: the treatment function for px eg nurse, midwife, consultant"

