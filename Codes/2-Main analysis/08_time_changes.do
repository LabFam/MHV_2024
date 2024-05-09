*---------------------------------------------------*
*		Changes over time                 			*
*---------------------------------------------------*


capture do 00_main

use   "$data\SES_appended.dta", replace


** Keeping the relevant sample
gen all_years= inlist(country, "BG", "CZ", "EE", "LT", "LV", "PL", "SK")
keep if all_years == 1
drop if mod(isco3d ,10 ) ==0 // Dropping observations with only 2-digit ISCO information (incl. military)
drop if mod(is883d ,10 ) ==0 // Dropping observations with only 2-digit ISCO information (incl. military)

capture drop aux
gen aux = isco3d if year>=2010
replace aux = is883d if year<2010

gen aft = year > 2006
capture drop occ_year
egen occ_year = group(aux aft)



** Observations per country
* For table 1
table country year 
collect export "$results/table__1_appendix_part2.xlsx" , replace


**#  Did selection into tasks change over time? 
*-----------------------------------------------------------

** Common options
global vce  "vce(cluster occ_year)"
global W    "[iw=weight_std]"

** Specifications
global demog "i.agen i.educ tenure"
global job	 "i.sector_agg firm_gt50 full_time"


eststo clear

foreach var of varlist ess* {

 
if strpos("`var'" , "mngmt") + strpos("`var'" , "care") >0 continue

		
local l_word = subinstr("`var'" , "_" ," ",.)
local n_w	 : word count `l_word'
local lword  = word("`l_word'", `n_w')

eststo small_2002_`lword' : reg `var' female##i.year  i.cn  $demog $job $W ///
		if year <2010 & all_years ==1  ,  $vce
 
eststo small_rec_`lword' : reg `var' female##i.year  i.cn  $demog $job $W ///
		if year >=2010 & all_years ==1  ,  $vce
		

}


**# Did returns to tasks changed over time? 
*------------------------------------------------


global wages     "log_eur18_hourly"
global tasks 	 "c.ess_analytical  c.ess_routine c.ess_manual c.ess_social"
global tasks_soc "c.ess_analytical c.ess_routine c.ess_manual c.ess_social_inward  c.ess_social_outward" 

	
eststo ret_small_2002: reg log_eur18_hourly ($tasks_soc)##i.female##i.year  i.cn  $demog $job share_fem $W ///
					if year< 2010 & all_years ==1 , $vce
 
eststo ret_small_rec: reg log_eur18_hourly ($tasks_soc)##i.female##i.year  i.cn  $demog $job share_fem $W ///
					if year>=2010 & all_years ==1 , $vce	
 
			
					
 *----------------------End of the estimation part-------------------------------*	
 
 sample 0.1
 
 
 
 **#      Returns to tasks 
 *--------------------------------------------------
 
 foreach task in social_inward social_outward analytical manual routine{
	estimates restore ret_small_2002
	margins , dydx(ess_`task') at(fem= (0 1) year= (2002 2006) ) level(90) post
	matrix part1 = r(table) 
	matrix colnames part1 = 2002#men 2006#men 2002#women  2006#women 
	
	estimates restore ret_small_rec 
	margins , dydx(ess_`task') at(fem= (0 1) year= (2010 2014 2018) ) level(90) post 
	matrix part2 = r(table) 
	matrix colnames part2 = 2010#men  2014#men 2018#men  2010#women 2014#women 2018#women 
	
	mat ret_`task' = part1, part2
	
}

foreach var in social_inward social_outward analytical manual routine{
	
matrix men_`var' 	= ret_`var'[1...,1..2],ret_`var'[1...,5..7]
matrix women_`var'  = ret_`var'[1...,3..4],ret_`var'[1...,8..10]

forvalues i = 1/5{ 
 if `i' ==1  matrix ret2_`var' = men_`var'[1..., `i'], women_`var'[1..., `i']
 if `i' !=1  matrix ret2_`var' = ret2_`var', men_`var'[1..., `i'], women_`var'[1..., `i']
  }

 matrix colnames men_`var' = 2002 2006 2010 2014 2018
 matrix colnames women_`var'= 2002 2006 2010 2014 2018

 
 } 
coefplot (matrix(men_social_inward), ci((5 6 )))(matrix(women_social_inward), ci((5 6 )) ) , bylabel("Social inward tasks") ||  ///
		(matrix(men_social_outward), ci((5 6 )))(matrix(women_social_outward), ci((5 6 )) ) , bylabel("Social outward tasks") ||  ///
		(matrix(men_analytical)    , ci((5 6 )))(matrix(women_analytical)  , ci((5 6 )) ) , bylabel("Analytical tasks") ||  ///
		(matrix(men_routine) 	 , ci((5 6 )))(matrix(women_routine) , ci((5 6 )) ) , bylabel("Routine tasks") ||  ///
		(matrix(men_manual)      , ci((5 6 )))(matrix(women_manual) , ci((5 6 )) ) , bylabel("Manual tasks") ||  ///
			,   yline(2.5 , lcolor(gs11)) xline(0)  xtitle("Wage returns") ///
		 legend(order(2 "men" 4 "women")) xsize(7) byopts( row(1)  )   

graph export "$results/Figure_4_wage_returns_by_year.pdf" , replace  as(pdf)
graph export "$results/Figure_4_wage_returns_by_year.wmf" , replace 		 
	


**#  Differences in tasks performed by men and women
*----------------------------------------------------

 foreach task in social social_inward social_outward analytical manual routine{
	
	local l_word = subinstr("`task'" , "_" ," ",.)
	local n_w	 : word count `l_word'
	local lword  = word("`l_word'", `n_w')

	estimates restore small_2002_`lword'
	margins r.female ,  at(year= (2002 2006) ) level(90) post
	matrix part1 = r(table) 
	matrix colnames part1 = 2002 2006
	
	estimates restore small_rec_`lword'
	margins r.female,    at(year= (2010 2014 2018) ) level(90) post 
	matrix part2 = r(table) 
	matrix colnames part2 = 2010 2014 2018
	
	mat ret_`task' = part1, part2
	
}	

 
coefplot matrix(ret_social)        , ci((5 6 ))  bylabel("Social tasks")  ||  /// 
		matrix(ret_social_inward)  , ci((5 6 ))  bylabel("Social inward tasks")  ||  ///
		matrix(ret_social_outward) , ci((5 6 ))  bylabel("Social outward tasks")  || ///  
		matrix(ret_analytical)     , ci((5 6 ))  bylabel("Analytic tasks" )  ||  ///
		matrix(ret_routine)        , ci((5 6 ))  bylabel("Routine tasks")   ||  ///
		matrix(ret_manual)         , ci((5 6 ))  bylabel("Manual tasks")   || , ///
		yline(2.5 , lcolor(gs11)) xline(0)  xtitle("Differences in frequency of tasks" "(women - men)" ) ///
		xsize(7) byopts( row(1)  )   
 
graph export "$results/Figure_5_tasks_differences_by_year.pdf" , replace  as(pdf)
graph export "$results/Figure_5_tasks_differences_by_year.wmf" , replace 		 



 
 

