*------------------------------------------------------------------*
*		Alternative definitions of tasks: care and management	
*------------------------------------------------------------------*

do 00_main

use "$data\SES_appended.dta", replace


** Main sample: 
keep if year == 2018 |( year ==2014 & country=="UK")
drop if inlist(country , "LU" , "MT" , "CY")
drop if mod(isco3d,10 ) ==0

 

**# Regressions: Returns to tasks
*---------------------------------------


eststo clear

global demog "i.agen i.educ tenure"
global job	 "i.sector_agg firm_gt50 full_time"
global vce   "vce(cluster isco3d)"
global W     "[iw=weight_std]"
 

* Returns to specific social tasks 
local tasks_soc "c.ess_analytical  c.ess_routine c.ess_manual c.ess_social_mngmt c.ess_social_care" 
eststo social_rob: reg log_eur18_hourly (`tasks_soc')##female $demog $job  share_fem i.cn $W  , $vce 
 
* Differences in specific tasks 
eststo management  : reg ess_social_mngmt i.female  $demog  $job i.cn $W , $vce level(90)
eststo care        : reg ess_social_care i.female  $demog  $job i.cn $W , $vce level(90)
 
 

**#  Printing table selection
*--------------------------------
 
 
 ** table options
global stats  `"N r2 rmse bic, label("N" "R-squared" "RMSE" "BIC") fmt(%9.0f  a3 a3 %9.0f ) "' 
global cells  `"b(star fmt(%9.3f)) se(par("[""]") fmt(%9.2f)) ci( par(( , ) ) fmt(%9.2f) )"' 
global stars "starlevels(* .1 ** .05 *** .01 )"
 

local print_to using "$results/table_a5_caremanagement.csv"
 
esttab social_rob management care `print_to' ,  cells( $cells ) stat( $stats )  replace label  nobase /// 
				csv coll(none) eqlab(none) keep(*female* *ess*) drop(*share*) ///
	             $stars level(90) order(1.female *mngmt* *care* *analytical* *routine* *manual*  )	///
				indicate( "Demographic characteristics= tenure"  ///
				"Job characteristics = firm_gt50" "Country FE = 3.cn") 