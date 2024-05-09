*-------------------------------------------*
*		Selection models (task)     		*
*-------------------------------------------*

capture do 00_main

use  "$data\SES_appended.dta", replace



** Main sample: year 2018
keep if year == 2018 |( year ==2014 & country=="UK")
drop if inlist(country , "LU" , "MT" , "CY")
drop if mod(isco3d,10 ) ==0

table  cn year
collect export "$results/table_a1_appendix_part1.xlsx" , replace
 
*--------------------------------------*
**#		Differences in tasks           *
*--------------------------------------*

global vce  "vce(cluster isco3d)"
global W    "[iw=weight_std]"

global demog "i.agen i.educ tenure"
global job	 "i.sector_agg firm_gt50 full_time "


eststo clear
foreach var of varlist ess* {

 
if strpos("`var'" , "mng") + strpos("`var'" , "care") >0 continue

local l_word = subinstr("`var'" , "_" ," ",.)
local n_w	 : word count `l_word'
local lword  = word("`l_word'", `n_w')
 
eststo l_`lword'  : reg `var' female  $demog  $job i.cn $W  , $vce

eststo l_`lword'_int : reg `var' female##i.cn   $demog  $job  $W  , $vce
 
}
	
*----------------------End of the estimation part-------------------------------*	
	
	
*----------------------------------------------------*
**#      	Tables with coefficients
*---------------------------------------------------*


** table options

global stats  `"N r2 rmse bic, label("N" "R-squared" "RMSE" "BIC") fmt(%9.0f  a3 a3 %9.0f ) "' 
global cells  `"b(star fmt(%9.3f)) se(par("[""]") fmt(%9.2f)) ci( par(( , ) ) fmt(%9.2f) )"' 
global stars "starlevels(* .1 ** .05 *** .01 )"


** Main Text
local print_to using "$results/table_3_diff_in_tasks.csv"

esttab l_social l_inward l_outward  l_analytical l_routine l_manual  `print_to' ,  ///
		csv replace label  cells( $cells ) stat( $stats )  level(90)  ///
		noleg nonotes noomit nobase  collab(none)  ///
		keep(female)   ///
		mlab(Social "Social inward" "Social outward" Analytical Routine Manual)  ///
		plain $stars
						  


** Appendix
local print_to using "$results/table_a4_appendix.csv"



esttab l_social l_inward l_outward  l_analytical l_routine l_manual  `print_to' ,   ///
		csv replace label  cells( $cells ) stat( $stats )  level(90)  ///
		noleg nonotes noomit nobase   collab(none) ///
		refcat( 2.agen "Age:" 2.education "Education level" 3.sector_agg "Industry" 3.cn "Country" , nolabel) ///
		mlab(Social "Social inward" "Social outward" Analytical Routine Manual) ///
		$stars

		
		
*------------------------------------------
**# 	FIGURE SELECTION : DIFFERENCES
*-----------------------------------------

  sample 0.1

** This sample reduction allows using the margins + estout commands to 
* produce the interactions. One could also do it "by hand".

foreach  var of varlist ess* {					  


if strpos("`var'" , "mng") + strpos("`var'" , "care") >0 continue

local l_word = subinstr("`var'" , "_" ," ",.)
local n_w	 : word count `l_word'
local lword  = word("`l_word'", `n_w')

local title : variable label `var'

 
est restor l_`lword'_int
eststo `lword'_fem : margins r.fem@cn,  post
 

coefplot `lword'_fem 	, xline(0) xtitle("Difference in task content" "(women - men)") ///
		title(`title') legend(off) note("`notess'") name(`lword'_1, replace) rename(r1vs0.female@* = "" )
		
}

graph combine social_1  inward_1 outward_1 analytical_1 routine_1  manual_1 ,  xcommon scheme(burd) r(1) xsize(7)
graph export "$results/Figure_3_diff_tasks_by_country.png" 		, replace
graph export "$results/Figure_3_diff_tasks_by_country.wmf"			, replace	


