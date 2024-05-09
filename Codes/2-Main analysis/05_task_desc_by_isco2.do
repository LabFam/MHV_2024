*-------------------------------------------*
*	 Tasks for different occupations		*
*-------------------------------------------*

capture do 00_main

use "$data/tasks_isco08_2d.dta", clear 

label var ess_social 	  "Social tasks"
label var ess_social_outward  "Social outward tasks" 
label var ess_social_inward  "Social inward tasks"
label var ess_analytical	  "Analytical tasks"
label var ess_routine  	  "Routine tasks"
label var ess_manual  	  "Manual tasks"

gen isco1d = floor(isco2d /10)

sort isco2d
gen xs = _n


foreach var in social analytical routine manual  social_outward social_inward {
	
local title : 	var l ess_`var'
	
twoway bar ess_`var' xs , xline( 3.5  7.5  13.5  18.5  22.5 26.5 28.5 33.5 36.5 , lcolor(gs11) ) xsize(4.5) ///
	 xlabel( 2 "0" 5.5 "1" 10.5 "2" 16 "3" 20.5 "4"	24.5 "5" 27.5 "6" 31 "7"  35 "8" 39.5 "9" ) name(`var', replace) ///
	ytitle("Task value""(standardized)") title("`title'" , size(medium))  xtitle("") // xtitle("ISCO 08 occupation code")

	}

graph combine social social_inward social_outward  analytical routine manual    , ///
		name(gr1, replace) xcommon b1title("ISCO 08 occupation code" , size(small)) xsize(5) ycommon
graph export "$results/Figure_1_tasks_by_isco2d.png" , replace
graph export "$results/Figure_1_tasks_by_isco2d.wmf" , replace

exit
