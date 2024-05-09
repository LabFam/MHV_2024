*-------------------------------------------------*
*		Working with EU Structure of Eanings Survey
*-------------------------------------------------*


capture do 00_paths

cd "$data_euses" // This is the path to raw EU SES files
global countries bg cy cz dk ee el fr hu it lt lu lv mt no pl se sk uk

local i = 1
foreach f of global countries {
	if ("`f'"=="fr") {
		global years 2006 2010 2014 2018
	}
	else if ("`f'"=="dk" | "`f'"=="mt" | "`f'"=="it") {
		global years 2014 2018
	}
	else if ("`f'"=="uk") {
		global years 2002 2006 2010 2014 
	}
	else if ("`f'"=="el") {
	    global years 2002 2014 2018
	}
	else if ("`f'"=="hu" | "`f'"=="se") {
	    global years 2002 2006
	}
	else if ("`f'"=="no") {
	    global years 2006 2018
	}
	else {
		global years 2002 2006 2010 2014 2018
	}	
	
	foreach y of global years {
		di in red "Country `f' in year `y'"
		if (`y'==2002 & "`f'"!="it") {
			local rowstart = 2
		}
		else {
			local rowstart = 1
		}
		import delimited "`f'/SES_`f'_`y'_ANONYM_CD.csv", clear rowrange(`rowstart')  varnames(`rowstart')
		
		cap destring b23, replace
		quietly gen isco_length=strlen(string(b23))
		
		cap gen country="`f'"
		tostring key_* a14, replace
		destring b25, replace ignore("G")
		destring a12, replace ignore("U")
		
		save "$temp_folder\a`i'.dta", replace
		local i = `i' + 1
	}
}

clear all 
 
forvalues i=1(1)68 {
	di in red "`i'"
    append using "$temp_folder\a`i'.dta"
	
}


replace country = "GR" if country=="EL"
encode country, gen(cn)

bysort country: egen start_year = min(year)
gen start = (year==start_year & (year==2002 | year==2006))



**# Personal characteristicss
*------------------------------------------

gen female = (b21=="F")
label var female        "Woman"

rename b22 age 
label var age        "Age"

encode age , gen(agen)
label var agen        "Age"
// Levels: 0-19, 20-29, 30-39, 40-49, 50-59, 60-98, 99-999 (1-7 in 2002)

gen education = . 
replace education = 1 if (b25<3 & inlist(year, 2002 , 2006 , 2010)) | (b25==1 & inlist(year, 2014 ,2018)) // ISCED'97 0-2
replace education = 2 if (b25>=3 & b25<9 & year==2002) | (b25==3 & (year==2006 | year==2010)) | (b25==2 & (year==2014 | year==2018)) // ISCED'97 3-4
replace education = 3 if (b25>=9 & b25<=11 & year==2002) | (b25>=4 & b25<=6 & (year==2006 | year==2010)) | (b25>=3 & b25<=4 & (year==2014 | year==2018)) // ISCED'97 5-6
label define education 1 "Lower secondary or lower" 2 "Upper or post-secondary" 3 "Any tertiary"
label values education education

/*
2002: 1 ISCED 0-1, 2 ISCED 2, 3 ISCED 3, 8 ISCED 4, 9 ISCED 5B, 10 ISCED 5A, 11 ISCED6 (4-7 as extended 3)
2006, 2010: 1 ISCED 0-1, 2 ISCED 2, 3 ISCED 3-4, 4 ISCED 5B, 5 ISCED 5A, 6 ISCED 6
2014, 2018: G1 Basic (0-lower sec), G2 Secondary (upper post-sec), G3 Tertiary (up to 4 years), G4 Tertiary (more than 4)
*/

gen weight = .
replace weight = b42 if year==2002
replace weight = b52 if year>=2006 & year<=2018

egen weight_tot = total(weight), by(cn year)
gen  weight_std = weight / weight_tot * 100



**#  Firm characteristics
*------------------------------------------------

* Firm size
rename a12 firm_size_cat // 1_9?? 10_49 50_249 250_499 500_999 1000_ in 2002, 2006, 2010
rename a16 firm_size_num
gen firm_gt50 = 0
replace firm_gt50 = 1 if a12_class!="" & a12_class!="all" & a12_class!="ALL" & a12_class!="All" & a12_class!="1_49"
rename a12_class firm_size_cat2
label var firm_gt50     "Firm over 50 employees"

* Sector of economic activity
rename a13 sector // NACE rev 1.1 in 2002, 2006; NACE rev. 2 in 2010.

replace nace = subinstr(nace, "X", "", .)
replace nace = "" if nace=="."

gen sector_agg = .
replace sector_agg = 1  if nace=="A" | nace=="B" & year < 2010
replace sector_agg = 2	if inlist(nace,"C","D","E") & year < 2010
replace sector_agg = 2  if sector=="C + E" & year < 2010
replace sector_agg = 3	if nace=="F" & year < 2010
replace sector_agg = 4	if nace>"F" & nace < "L" & year < 2010
replace sector_agg = 5	if nace>"K" & nace != "" & year < 2010

replace sector_agg = 1  if nace=="A" & year >= 2010
replace sector_agg = 2	if inlist(nace,"B","C","D","E") & year >= 2010
replace sector_agg = 2  if sector=="B" & year >= 2010
replace sector_agg = 3	if nace=="F" & year >= 2010
replace sector_agg = 4	if nace>"F" & nace < "O" & year >= 2010
replace sector_agg = 5	if nace>"M" & nace != "" & year >= 2010

label define ind 1 "Agriculture" 2 "Manufacturing" 3 "Construction" 4 "Market services" 5 "Non-market services"
label values sector_agg ind

tab sector_agg, gen(sector_)

gen private = (a14=="B")   // public private shared in 2002; public private in 2006, 2010, 2014 2018



**# Position characteristics
*-----------------------------------------

rename b26 tenure 
label var tenure	"Tenure" 
replace tenure = . if tenure >= 95


gen full_time = (b27=="FT")
label var full_time    "Full time position"


rename b271 perc_time

rename b28 contract
replace contract = "indefinite"         if upper(contract)=="A"
replace contract = "fixed"              if upper(contract)=="B"
replace contract = "apprentice-trainee" if upper(contract)=="C"
replace contract = "other"              if upper(contract)=="D"
replace contract = ""      if !inlist(contract,"indefinite","fixed", "apprentice-trainee" ,"other")

encode contract, gen(contract_num)

 
 
**# Wages / hourly wages
*---------------------------------------------------------------

gen monthly_wage 	 = . // gross earnings in reference month
replace monthly_wage = b31 if year==2002 
replace monthly_wage = b42 if year>=2006 & year<=2018

gen hourly_wage 	= . // average gross hourly earnings in the reference month
replace hourly_wage = b30 if year==2002
replace hourly_wage = b43 if year>=2006 & year<=2018

gen hours = . // number of hours paid during the reference month
replace hours = b34 if year==2002
replace hours = b32 if year>=2006 & year<=2018



gen eur_monthly = monthly_wage
gen eur_hourly = hourly_wage
	
compress
save "$data\SES_appended.dta", replace	
	
/* EXCHANGE RATES */
//sources: https://sdw.ecb.europa.eu/quickview.do;jsessionid=C2609BA40FB4CEEF842B2B990E06263A?SERIES_KEY=120.EXR.Q.CYP.EUR.SP00.A&start=&end=&submitOptions.x=0&submitOptions.y=0&trans=AF;
//https://exchangerates.org/eur/bgn/in-2002; central banks (Malta and Cyprus?)
foreach year in 2002 2006 2010 2014 2018 {
	if ("`year'"=="2002") {
		foreach var of varlist eur_monthly eur_hourly {
			replace `var'=`var'/1.950061 if country=="BG" & year==`year'
			replace `var'=`var'/0.57532  if country=="CY" & year==`year'
			replace `var'=`var'/30.821   if country=="CZ" & year==`year'
			replace `var'=`var'/242.95   if country=="HU" & year==`year'
			replace `var'=`var'/15.6466  if country=="EE" & year==`year'
			replace `var'=`var'/3.4528   if country=="LT" & year==`year'
			replace `var'=`var'/0.6      if country=="LV" & year==`year'
			replace `var'=`var'/3.855473 if country=="PL" & year==`year'
			replace `var'=`var'/0.80612  if country=="UK" & year==`year'
			replace `var'=`var'/7.43168  if country=="DK" & year==`year'
			replace `var'=`var'/0.4087   if country=="MT" & year==`year'
			replace `var'=`var'/7.512318 if country=="NO" & year==`year'
			replace `var'=`var'/9.162107 if country=="SE" & year==`year'
			replace `var'=`var'/42.692   if country=="SK" & year==`year'
			replace `var'=`var'/0.62872  if country=="UK" & year==`year'
		}
	}
	if ("`year'"=="2006") {
		foreach var of varlist eur_monthly eur_hourly {
			replace `var'=`var'/1.95675  if country=="BG" & year==`year'
			replace `var'=`var'/0.57578  if country=="CY" & year==`year'
			replace `var'=`var'/28.3394  if country=="CZ" & year==`year'
			replace `var'=`var'/264.149  if country=="HU" & year==`year'
			replace `var'=`var'/15.6466  if country=="EE" & year==`year'
			replace `var'=`var'/3.4528   if country=="LT" & year==`year'
			replace `var'=`var'/0.703    if country=="LV" & year==`year'
			replace `var'=`var'/3.896538 if country=="PL" & year==`year'
			replace `var'=`var'/8.047236 if country=="NO" & year==`year'
			replace `var'=`var'/0.80612  if country=="UK" & year==`year'
			replace `var'=`var'/7.45985  if country=="DK" & year==`year'
			replace `var'=`var'/0.4293   if country=="MT" & year==`year'
			replace `var'=`var'/9.252758 if country=="SE" & year==`year'
			replace `var'=`var'/37.235   if country=="SK" & year==`year'
			replace `var'=`var'/0.681823 if country=="UK" & year==`year'
		}
	}
	if ("`year'"=="2010") {
		foreach var of varlist eur_monthly eur_hourly {
			replace `var'=`var'/1.956444 if country=="BG" & year==`year'
			replace `var'=`var'/25.303   if country=="CZ" & year==`year'
			replace `var'=`var'/275.361  if country=="HU" & year==`year'
			replace `var'=`var'/15.6466  if country=="EE" & year==`year'
			replace `var'=`var'/3.4528   if country=="LT" & year==`year'
			replace `var'=`var'/0.703    if country=="LV" & year==`year'
			replace `var'=`var'/3.996694 if country=="PL" & year==`year'
			replace `var'=`var'/8.009314 if country=="NO" & year==`year'
			replace `var'=`var'/0.80612  if country=="UK" & year==`year'
			replace `var'=`var'/7.44701  if country=="DK" & year==`year'
			replace `var'=`var'/9.547691 if country=="SE" & year==`year'
			replace `var'=`var'/0.858401 if country=="UK" & year==`year'
		}
	}
	if ("`year'"=="2014") {
		foreach var of varlist eur_monthly eur_hourly {
			replace `var'=`var'/1.9558   if country=="BG" & year==`year'
			replace `var'=`var'/27.536   if country=="CZ" & year==`year'
			replace `var'=`var'/308.613  if country=="HU" & year==`year'
			replace `var'=`var'/7.453    if country=="DK" & year==`year'
			replace `var'=`var'/3.4528   if country=="LT" & year==`year'
			replace `var'=`var'/8.35803  if country=="NO" & year==`year'
			replace `var'=`var'/4.1843   if country=="PL" & year==`year'
			replace `var'=`var'/0.80612  if country=="UK" & year==`year'
			replace `var'=`var'/9.098924 if country=="SE" & year==`year'
		}
	}
	if ("`year'"=="2018") {
		foreach var of varlist eur_monthly eur_hourly {
			replace `var'=`var'/1.9558   if country=="BG" & year==`year'
			replace `var'=`var'/25.647   if country=="CZ" & year==`year'
			replace `var'=`var'/318.716  if country=="HU" & year==`year'
			replace `var'=`var'*0.1341   if country=="DK" & year==`year'
			replace `var'=`var'/9.5975   if country=="NO" & year==`year'
			replace `var'=`var'/4.2615   if country=="PL" & year==`year'
			replace `var'=`var'/10.2616  if country=="SE" & year==`year'
			replace `var'=`var'/0.885041 if country=="UK" & year==`year'
		}
	}
}
//Euro fully introduced in France,Italy, LU in Jan-Feb 2002

capture drop eur18* 
gen eur18_hourly = eur_hourly
gen eur18_monthly = eur_monthly
foreach var of varlist eur18* {
	replace `var' = `var' * 1.3079 if year == 2002
	replace `var' = `var' * 1.197  if year == 2006
	replace `var' = `var' * 1.1103 if year == 2010
	replace `var' = `var' * 1.0254 if year == 2014
}

capture drop log_eur18_hourly
gen log_eur18_hourly = log(eur18_hourly)




local cvars     "country cn year weight_std weight weight_tot"
local demovars "female age agen educ"
local firmvars "firm_gt50 private sector_agg"
local posvars  "tenure full_time contract contract_num log_eur18_hourly b23"

keep   `cvars' `demovars' `firmvars' `posvars'

compress

save "$data\SES_appended.dta", replace


**# Occupations
*-------------------------------------------


gen is883d = b23 if year==2002 | year==2006
gen isco08 = b23 if year>=2010 & year<=2018



cd "$data"
capture drop _merge
merge m:1 is883d using "tasks_isco88_2018_stdlfs.dta"  , update
rename _merge _merge88
drop if _merge88==2

rename isco08 isco3d
merge m:1 isco3d using "tasks_isco08_2018_stdlfs.dta", update
rename _merge _merge08
drop if _merge08==2

drop if mi(country, year) 

label var ess_social 			"Social tasks"
label var ess_analytical		"Analytical tasks"
label var ess_routine 			"Routine tasks"
label var ess_manual			"Manual tasks"

label var ess_social_outward	"Social outward tasks"
label var ess_social_inward		"Social inward tasks"

label var ess_social_mngmt     	"Social tasks: management"
label var ess_social_care 		"Social tasks: caring"


replace isco3d=isco3d*10 if isco3d < 100
drop if isco3d==999

gen isco1d = floor(isco3d/100)
drop if isco1d ==0

save "$data\SES_appended.dta", replace

**# Share of women in a given occupation
*----------------------------------------------

gen anyisco = cond(!mi(isco3d), isco3d, is883d)
drop if mi(anyisco)									
// SE 2002, 36 690 obs without code (out of 1 million)


collapse (mean) share_female= female [iw = weight_tot] , by(cn isco3d year)
compress
label var share_female "Share of women in occ."

save "$data/share_female" , replace

 

use "$data/SES_appended.dta", replace

merge m:1 cn isco3d year using "$data/share_female"

erase "$data/share_female.dta"


save "$data/SES_appended.dta", replace


** Cleaning
forvalues i=1(1)68 {
	erase "$temp_folder\a`i'.dta"
}


exit 




