*-----------------------------------------------*
*			Weights from EU - LFS				*	
*-----------------------------------------------*

 
capture do 00_main

global src "$data_eulfs"
 
capture frame drop outputs
frame create outputs

global f_list  : dir "$src" files "*.dta"
foreach ff in $f_list{

	if strpos("`ff'" , "appended") != 0 continue	// auxiliary file		
    if strpos("`ff'" , "margins") != 0 continue	
	
	** File names follow the convention datasrc_year_country, for example eulfs_2020_pl
	tokenize "`ff'" , parse("_" ".")
	local year     "`3'"
	local country  "`5'"
	

	if `year' <2002 continue

	use ${data_eulfs}/`ff' , clear
	
	
	if `year' <= 2010 local occ  "is883d"
	if `year' >  2010 local occ  "isco3d"
	
	capture drop if `occ' == 999 | mi(`occ')
	
	
	gen weight_LFS = 1
	collapse (sum) weight_LFS (first) year eu_code [pw=weight_ppl_cross], by(`occ') 
	
	tempfile weights
	save `weights' , replace
			
	frame outputs : append using `weights'
	
	clear	
}


frame change outputs
 
gen last_digit 		= real(substr(string(isco3d),-1,1))
replace last_digit 	= real(substr(string(is883d),-1,1)) if mi(last_digit)

bys eu_code year: egen less_three = max(last_digit)
recode less_three (0=1) (1/9=0)

gen source = "EULFS"

bys eu_code year : egen all_obs = total(weight) 

version 16 : table eu_code year , c(mean all_obs)


save "$data/weights_EU_LFS" , replace

*------------------------------------------------------------------------------*

frame change default

capture frame drop outputs
frame create outputs

forvalues yy = 2014/2018{
use "$data_pl/LFS_Poland_`yy'" , clear
ren isco kzis_14
drop if mi(kzis_14)


merge m:1 kzis_14 using "$data_pl/../original_data/CW_kzis14_isco08" // see: https://ibs.org.pl/en/resources/occupation-classifications-crosswalks-from-isco-to-kzis/

if `yy' ==2014{
	replace isco_08 = "2262" if inrange(kzis_14 , 2283, 2289) 			// Same as others 228 and 229 ~400 obs
	replace isco_08 = "3334"  if kzis_14 ==2441
	replace isco_08 = "110"  if kzis_14 ==111
	replace isco_08 = "210"  if kzis_14 ==211
	replace isco_08 = "310"  if kzis_14 ==311
	}

	
	
	
drop if mi(isco_08) | _merge==2		// some observations had a missing occupation code (x999)
destring isco_08, replace
gen isco3d = floor(isco_08/10)

	
gen weight_LFS = 1

collapse (sum) weight_LFS (first) year eu_code [pw=weight_ppl_cross], by(isco3d) 

tempfile weights_pl
save `weights_pl'

frame outputs: append using `weights_pl'


}

clear
frame change outputs
gen source = "LFS_PL"
bys eu_code year : egen all_obs = total(weight) 
replace eu_code = lower(eu_code)

append using "$data/weights_EU_LFS"

table source year if eu_code =="pl" & inrange(year, 2014,2018) , stat(mean all_obs) stat( sd all_obs)

replace weight_LFS = weight_LFS/4 if source =="LFS_PL"			// So that it is comparable with EU-LFS_PL


label data "Weights for different occupations"
notes: Covers period 2002-2018 with interruptions
save "$data/weights_all" , replace

/* Create EU-level averages */
use "$data/weights_all", clear
keep if year==2018 & (eu_code!="pl" | source=="LFS_PL")
drop if less_three==1
collapse (sum) weight, by(isco3d)
drop if floor(isco3d/10)==isco3d/10

save "$data/weights_EUavg", replace