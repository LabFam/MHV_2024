*---------------------------------------*
*			Wage regressions			*
*---------------------------------------*

capture do 00_main

use  "$data\SES_appended.dta", replace


** Main sample: 
keep if year == 2018 |( year ==2014 & country=="UK")
drop if inlist(country , "LU" , "MT" , "CY")
drop if mod(isco3d,10 ) ==0



**#   Regressions: Returns to tasks
*---------------------------------------

global wages     "log_eur18_hourly"
local tasks 	 "c.ess_social c.ess_analytical c.ess_routine c.ess_manual"
local tasks_soc  "c.ess_social_outward c.ess_social_inward c.ess_analytical c.ess_routine c.ess_manual " 
global demog     "i.agen i.educ tenure"
global job	     "i.sector_agg firm_gt50 full_time "

global vce  "vce(cluster isco3d)"
global W    "[iw=weight_std]"


eststo clear

* Returns to tasks 
eststo sf_base1: reg $wages  `tasks'       i.female $demog $job i.cn share_female  $W  , $vce
eststo sf_soc1:  reg $wages  `tasks_soc'   i.female $demog $job i.cn share_female  $W  , $vce

* Including interactions with genders 
eststo sf_base2: reg $wages (`tasks')##female       $demog $job i.cn share_female $W  , $vce 
eststo sf_soc2:  reg $wages (`tasks_soc')##female   $demog $job  i.cn share_female $W  , $vce 


* Country heterogeneity
eststo earn_base_join: reg $wages (`tasks')##female##cn  $demog $job  share_female  $W  , $vce 
eststo earn_soct_join: reg $wages (`tasks_soc')##female##cn  $demog $job   share_female  $W  , $vce 



**# WAGE RETURNS BY GENDER  
*-----------------------------------------
 
 
sample 0.01 

** Reducing the sample allows obtaining point estimates and CI using the margins
* command much faster, which can later be fed to the estout package
* It is also possible to do it by hand. 

foreach model in sf_base1 sf_soc1 sf_base2 sf_soc2  {

local vars " "
local vars = cond(strpos("`model'","soc")!=0, "c.ess_social_inward c.ess_social_outward" , "c.ess_social")	
local vars `vars' c.ess_analytical c.ess_routine c.ess_manual	


foreach var in `vars' 	{		


tokenize "`var'" , parse("." "_")
local vname  = cond("`5'" =="social" & "`7'"!="" , "`7'" , "`5'")

tokenize "`model'" , parse("_")
local mid = "`3'"

estimates restore `model'

if strpos("`model'","1")!=0{        // models without interactions
	
	margins , dydx(`var') atmeans	post
	estimates store `mid'_`vname'
	}	 
 
 if strpos("`model'", "2")!=0{       // models with interactions
	contrast r.fem#`var'
	scalar pval = el(r(p),1,1)
 	
	margins , dydx(`var') at(female=0 female=1)  post
	estimates store `mid'_`vname'
	estadd scalar pval 
	}


}			
}

** Results Table 2
*--------------------------------

** table options
global stats  N r2 , label("N" "R-squared") fmt(0 3)
global stars starlevels(* .1 ** .05 *** .01 )

		
local print_to  using "$results/table_2_wage_returns.csv"
global cells  `"b(star fmt(%9.3f)) se(par("[""]") fmt(%9.2f)) ci( par(( , ) ) fmt(%9.2f) )"' 
esttab base1_* `print_to'	, rename(ess_social "Task"  ess_analytical "Task" ///
			ess_routine "Task"  ess_manual "Task" )  ///
			mlabel("Social" "Analytic" "Routine" "Manual") ///
			eqlabel(none) nonumber collabel(none) $stars nonotes cell($cells) stat() level(90) replace 
				
esttab soc1_* `print_to'	, rename(ess_social_inward "Task" ess_social_outward "Task"  ///
			ess_analytical "Task" ess_routine "Task"  ess_manual "Task" )  ///
			mlabel("Social inward" "Social outward" "Analytic" "Routine" "Manual") ///
			eqlabel(none) nonumber collabel(none) $stars nonotes cell($cells) level(90) append		
			
esttab base2_* `print_to'	, stats(pval , label("p-value"))  varlabel(1._at "Men" 2._at "Women") ///
			mlabel("Social" "Analytic" "Routine" "Manual") ///
			eqlabel(none) nonumber collabel(none) $stars nonotes cell($cells) append level(90)
				
esttab soc2_* `print_to'	, stats(pval , label("p-value"))  varlabel(1._at "Men" 2._at "Women") ///
			mlabel("Social inward" "Social outward" "Analytic" "Routine" "Manual") ///
			eqlabel(none) nonumber collabel(none) $stars nonotes cell($cells) append  level(90)

			
	
			

	
** Full table for the Appendix
*---------------------------------
local print_to  using "$results/table_a3_appendix.csv"
global stats  `"N r2 rmse bic, label("N" "R-squared" "RMSE" "BIC") fmt(%9.0f  a3 a3 %9.0f ) "' 
global cells  `"b(star fmt(%9.3f)) se(par("[""]") fmt(%9.2f)) ci(  par(( , ) ) fmt(%9.2f) )"' 
global stars starlevels(* .1 ** .05 *** .01 )

esttab sf_base1 sf_soc1 sf_base2 sf_soc2     `print_to'	,  label replace  cell($cells) $stars ///
				eqlabel(none) nonumber collabel(none) noomit nonotes nobase stat($stats) ///
				order(1.female ess_soc* ess_ana* ess_rout* ess_man* 1.female*ess_soc* ///
				 1.female*ess_ana*  1.female*ess_rou*  1.female*ess_man* *age* *educ* ///
				 tenure  full_time *sector_agg* firm* *share* )  ///
				 refcat(ess_social "Tasks:" 1.female#ess_social "Interactions:" ///
				 2.agen "Age:" 2.education "Education level" 3.sector_agg "Industry" 3.cn "Country" , nolabel) ///
				 prehead("Dependent variable: log hourly wage (EUR)")  ///
				 mtitle("1a" "1b" "2a" "2b")  level(90)   
				 

				 
				 
			 
**# Heterogeneity across countries
*---------------------------------------

levelsof country if e(sample) , local(names)

foreach task in social_inward social_outward analytical manual routine{
	estimates restore earn_soct_join
	margins cn , dydx(ess_`task') at(fem= (0 1)  ) level(90) post
	mat ret_`task' = r(table) 

	mat colnames ret_`task' = `names' `names'

	mat men_`task' = ret_`task'[1..7, 1..13]
	mat wom_`task' = ret_`task'[1..7, 14..26]
}
	
 
	
coefplot (matrix(men_social_inward) , ci((5 6 )) ) (matrix(wom_social_inward) , ci((5 6 )) ) , bylabel("Social inward tasks") ||  ///
		 (matrix(men_social_outward), ci((5 6 )) ) (matrix(wom_social_outward) , ci((5 6 )) ) , bylabel("Social outward tasks") ||  ///
		 (matrix(men_analytical)    , ci((5 6 )) ) (matrix(wom_analytical) , ci((5 6 )) ) , bylabel("Analytical tasks") ||  ///
		 (matrix(men_routine) 	    , ci((5 6 )) ) (matrix(wom_routine)    , ci((5 6 )) ) , bylabel("Routine tasks") ||   ///
		 (matrix(men_manual)        , ci((5 6 )) ) (matrix(wom_manual)     , ci((5 6 )) ) , bylabel("Manual tasks") || , ///
		 xline(0)  xtitle("Wage returns") ///
		 legend(order(2 "men" 4 "women")) xsize(7) byopts( row(1)  )   name(fig1, replace)
 
graph export "$results/Figure_2_wage_returns_by_country.png" , replace
graph export "$results/Figure_2_wage_returns_by_country.wmf" , replace		 




**#   Differences in returns by country: detailed analysis 
*---------------------------------------------------------------

estimates restore earn_soct_join
levelsof country , local(names)	
levelsof cn , local(cc)	

foreach task in social_inward social_outward analytical manual routine {
	
	matrix `task' = J(13, 2, .)
	matrix rownames `task' = `names'
	matrix colnames `task' = Difference pvalue
	
	local i = 1
		foreach c in `cc'{
			local dif : di %5.4f   _b[1.female#c.ess_`task'] + _b[1.female#`c'.cn#c.ess_`task']
	
			quiet test  _b[1.female#c.ess_`task'] + _b[1.female#`c'.cn#c.ess_`task'] = 0
			local pval : di %6.4f   `r(p)'
	
			matrix `task'[`i', 1] = `dif' ,`pval'

	local ++i
	}


	di ""
di "Differences in returns across countries for `task'"	
matrix l `task'
}

matrix all_results = social_inward, social_outward , analytical , routine , manual

putexcel set "$results/table_b1_cross_country_comp.xlsx", replace

putexcel A1= "Differences in returns to tasks across countries"
putexcel B2 = "Social Inward" D2 = "Social outward" F2= "Analytical"  H2= "Routine"  J2="Manual"

putexcel A3 = matrix(all_results) , names nformat(number_d2)
 
