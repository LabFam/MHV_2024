*-----------------------------------------------------------*
*		Obtaining measures of tasks at the EU level			*
*-----------------------------------------------------------*


capture do 00_paths

import delimited "$data_tasks/esco_onet_matysiaketal2024.csv" , clear

// Use non-routine features to better assess routine
replace tasks_routine     = tasks_routine - tasks_nonroutine
replace ess_tasks_routine = ess_tasks_routine - ess_tasks_nonroutine
replace opt_tasks_routine = opt_tasks_routine - opt_tasks_nonroutine

drop tasks_nonroutine ess_tasks_nonroutine opt_tasks_nonroutine

ren *_tasks* **


**#  Going from ESCO-level to ISCO-08 
*----------------------------------------
collapse (sum) tasks_* ess_* opt_* (mean) t_* (lastnm) isco08 , by(occupationcode)

 
// Dots in the ESCO code allow to identify the level of detail
gen ndots = length(occupationcode) - length(subinstr(occupationcode, ".", "", .))
gen ldot = strrpos(occupationcode, ".")
replace occupationcode = substr(occupationcode, 1, ldot-1) if ndots==4

collapse (mean) tasks_* ess_* opt_* t_* (lastnm) isco08 (min) ndots, by(occupationcode)
gen ldot = strrpos(occupationcode, ".")
replace occupationcode = substr(occupationcode, 1, ldot-1) if ndots==3

collapse (mean) tasks_* ess_* opt_* t_* (lastnm) isco08 (min) ndots, by(occupationcode)
gen ldot = strrpos(occupationcode, ".")
replace occupationcode = substr(occupationcode, 1, ldot-1) if ndots==2

collapse (mean) tasks_* ess_* opt_* t_* (lastnm) isco08 (min) ndots, by(occupationcode)

// Final reduction to regular ISCO-08 (4-digit at this point)
collapse (mean) tasks_* ess_* opt_* t_*, by(isco08)


/* Adding EU-wide weights from EU-LFS 2018 */
gen isco3d = int(isco08/10)
merge m:1 isco3d using "$data/weights_EUavg"

drop if _merge==2

/* Remembering the data and importing crosswalks for ISCO-08 - ISCO-88 */
tempfile temp
save `temp'

// ISCO-88 - ISCO-08 correspondence table
import excel "$data_tasks\corrtab88-08.xls", clear first
destring _all, replace
rename ISCO08Code isco08
rename ISCO083digit isco3d

// Merging with data on shares of small-firm managers in occupations in 2011 (see explanation in lines 130--139)
merge m:1 isco3d using "$data_tasks/mngmt_shares.dta"

drop if _merge==2
drop _merge

tempfile temp2
save `temp2'

use `temp', clear

drop _merge
merge 1:m isco08 using `temp2'

drop if _merge==2

rename ISCO883digit is883d
 

 	
**# Standardizing the variables (ISCO 08 , 3 digits)
*-----------------------------------------------------*	
preserve
	collapse (mean) tasks_* ess_* opt_* t_* (lastnm) weight_LFS, by(isco3d)
	
foreach var of varlist t_* tasks_* ess* opt* {
			sum `var' [iw=weight_LFS]
			replace `var' = (`var' - r(mean)) / r(sd) 
			
			local avg_`var' = r(mean)
			local sd_`var' = r(sd)
	}
	
	egen onet_nrca=rowtotal(t_4a2a4 t_4a2b2 t_4a4a1)
	egen onet_nrcp=rowtotal(t_4a4a4 t_4a4b4 t_4a4b5)
	egen onet_rcog=rowtotal(t_4c3b7 t_4c3b4 t_4c3b8_rev)
	egen onet_rman=rowtotal(t_4c3d3 t_4a3a3 t_4c2d1i)
	egen onet_nrma=rowtotal(t_4a3a4 t_4c2d1g t_1a2a2 t_1a1f1)

	foreach var of varlist onet_* {
		summ `var' [iw=weight_LFS]
		replace `var'= (`var'- r(mean) ) / r(sd)
		 
		local avg_`var' = r(mean)
		local sd_`var' = r(sd)
	}
		
	gen onet_abstract = onet_nrca + onet_nrcp
	gen onet_routine = onet_rcog + onet_rman
	gen onet_manual = onet_nrma

	foreach var of varlist onet_abstract onet_routine onet_manual {
		summ `var' [iw=weight_LFS]
		replace `var'= (`var'- r(mean) ) / r(sd) 
		
		local avg_`var' = r(mean)
		local sd_`var' = r(sd)
	}
	
	drop t_*  

	compress

	  save "$data/tasks_isco08_2018_stdlfs.dta", replace
restore

 
**#  Standardizing the variables (ISCO 88 , 3 digits)
*-------------------------------------------------------*

/* ISCO-88 occupation 131 is "Managers of small enterprises" and has been split across different 3-digit level occupations for ISCO-08. To account for that with the crosswalk, we follow these steps:

1) we calculate the (weighted) shares of small-firm supervisors in 3-digit ISCO-08 occupations in 2011, using EU LFS data for all countries with 3-digit ISCO information. These shares are merged with these data in line 61.

2) in lines 154-167 we identify all ISCO-08 occupations matched to the ISCO-88 131 occupation. We then calculate average task scores for the 131 occupation by weighing each ISCO-08 occupations with the share of small-firm supervisors among the workers in that occupation.

3) we use that score for ISCO-88 131 occupation.

In summary: the ISCO-88 scores consider matched ISCO-08 occupations but instead of giving them equal weights, we weigh them by their size and the share of small-firm managers within them.
*/

preserve
	keep if is883d==131
	
	gen weight_mng = .
	
	levelsof isco3d, local(is08)
	foreach occ of local is08 {
	    tab isco08 if isco3d==`occ'
		replace weight_mng = share / r(N) if isco3d==`occ'
	}
	collapse (mean) tasks_* t_* ess_* opt_* [iw=weight_mng], by(is883d)

	tempfile o131
	save `o131'
restore

collapse (mean) tasks_* t_* ess_* opt_*, by(is883d)
drop if is883d==131
append using `o131'

foreach var of varlist t_* tasks_* ess* opt* {
	replace `var' = (`var' - `avg_`var'') / `sd_`var''
}
	
egen onet_nrca=rowtotal(t_4a2a4 t_4a2b2 t_4a4a1)
egen onet_nrcp=rowtotal(t_4a4a4 t_4a4b4 t_4a4b5)
egen onet_rcog=rowtotal(t_4c3b7 t_4c3b4 t_4c3b8_rev)
egen onet_rman=rowtotal(t_4c3d3 t_4a3a3 t_4c2d1i)
egen onet_nrma=rowtotal(t_4a3a4 t_4c2d1g t_1a2a2 t_1a1f1)

foreach var of varlist onet_* {
	replace `var' = (`var' - `avg_`var'') / `sd_`var''
}
		
gen onet_abstract = onet_nrca + onet_nrcp
gen onet_routine = onet_rcog + onet_rman
gen onet_manual = onet_nrma

foreach var of varlist onet_abstract onet_routine onet_manual {
	replace `var' = (`var' - `avg_`var'') / `sd_`var''
}

	drop t_* 
save "$data/tasks_isco88_2018_stdlfs.dta", replace



*--------------------------------------------------------------------------*

* Databases for two digit ISCO codes
*----------------------------------------

use "$data/tasks_isco08_2018_stdlfs.dta", replace
gen isco2d	= floor(isco3d/10)
gen ones 	= 1

collapse (mean) tasks* ess* opt* onet* (sum) ones [iw=weight_LFS] , by(isco2d)


label data "Measures at 2 digit, standardized using  LFS 2018"
save "$data/tasks_isco08_2d.dta", replace

*------------------------------------------------------------------------*