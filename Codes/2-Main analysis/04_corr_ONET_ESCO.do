*-----------------------------------------------*
*		Describing correlation with O*NET		*
*-----------------------------------------------*

capture do 00_main

use "$data/tasks_isco08_2018_stdlfs.dta", replace

gen ess_abstract = (ess_social + ess_analytical) / 2

label var ess_abstract 	  "Abstract tasks (ESCO)"
label var ess_social 	  "Abstract social tasks (ESCO)"
label var ess_social_outward  "Social tasks: outward"
label var ess_social_inward  "Social tasks: inward"
label var ess_analytical	  "Abstract technical/analytical tasks (ESCO)"
label var ess_routine  	  "Routine tasks (ESCO)"
label var ess_manual  	  "Manual tasks (ESCO)"

label var onet_abstract	  "Abstract tasks (O*Net)"
label var onet_nrca		  "Non-routine cognitive analytical tasks (O*Net)"
label var onet_nrcp	  	  "Non-routine cognitive interpersonal tasks (O*Net)"
label var onet_routine    "Routine tasks (O*Net)"
label var onet_manual  	  "Manual tasks (O*Net)"

local onet_vars	onet_abstract onet_nrca onet_nrcp onet_routine onet_manual
local esco_vars ess_abstract ess_analytical ess_social ess_routine ess_manual

// distinct ess_abstract onet_abstract ess_techarts onet_nrca ess_social ess_social_ext ess_social_int onet_nrcp ess_routine onet_routine ess_manual onet_manual

putexcel set "$results/table_a1_appendix_.xlsx", modify	
putexcel A1 = "ESCO name"
putexcel B1 = "ONET name"
putexcel C1 = "Pearson"
putexcel D1 = "Pearson (weighted)"
putexcel E1 = "Spearman"

forvalues i = 1 / 5 {

	local row = `i'+1

	local v1 : word `i' of `onet_vars'
	local v2 : word `i' of `esco_vars'	
	
	putexcel A`row' = "`v2'"
	putexcel B`row' = "`v1'"

	di ""
	di in red "`v1' vs `v2'"

	di ""
	di in red "Pair-wise"
	pwcorr `v1' `v2'
	
	putexcel C`row' = `r(rho)'

	
	di ""
	di in red "Pair-wise with weights"
	pwcorr `v1' `v2' [aw=weight]

	putexcel D`row' = `r(rho)'
	
	di ""
	di in red "Spearman"
	spearman `v1' `v2'  

	putexcel E`row' = `r(rho)'
	
	local rho : display %4.3f `r(rho)'
	local star = cond(r(p) > .10 , "" , cond(r(p) > .05, "*", cond(r(p) >.01, "**", "***" )))

	scatter `v1' `v2' , xsize(5) scheme(burd) ///
				note("Spearman's {&rho} = `rho' `star'" ) name(gr`i' , replace)

	egen `v1'_rank = rank(`v1')	
	egen `v2'_rank = rank(`v2')		
	di ""
	di in red "Spearman with weights"
	pwcorr `v1'_rank `v2'_rank [aw=weight]
	drop `v1'_rank `v2'_rank
} 

graph combine gr1 gr2 gr3 gr4 gr5, name(gr6, replace)  scheme(burd) r(1)  xsize(9)
// graph export "$results/table__1_ap.png" , replace
// graph export "$results/gr_esco_onet_23062022.wmf" , replace
