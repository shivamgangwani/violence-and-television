// Exploratory data analysis


/* Basic setup & config */
clear
set more off  
cd "/Users/shgwani/Desktop/IHDS_STATA"

ssc install outreg2, replace

use 03_merged/merged.dta, clear
gen ln_copc = ln(COPC)
label variable ln_copc "Log per-capita household consumption expenditure"

gen high_edu = EW8 > 5
label variable high_edu "Well-educated (more yrs of schooling than median)"

egen wifebeat_index = rowmean(GR34 GR35 GR36 GR37 GR38 GR39)

label variable wifebeat_index ///
    "Perceived community acceptance of wife beating"
	
	

/* 
Variables that we plan to use
X: MM3W -> "Regularly", "Sometimes", "Never" (How often do you watch TV: Women) [Categories]
Y: wifebeat_index -> Mean of (GR34 to GR39) [Number between 0 to 1]

Other controls:
COPC -> Household consumption expenditure [Number]
ln(COPC) -> log of COPC [Number]
GROUPS -> Caste ('Brahmin 1' < 'Forward caste 2' < 'Other Backward Castes (OBC) 3' < 'Dalit 4' < 'Adivasi 5' < 'Muslim 6' < 'Christian, Sikh, Jain 7') [Categories]
STATEID -> State fixed effects [Integer, IDs]
URBAN2011 -> 1 if urban, 0 if rural [Dummy]
EW6 -> Age (self) [Integer]
EW8 -> Years of education completed (self) [Integer]
SPED6 -> Years of education completed (spouse) [Categories]
*/

/*
reg wifebeat_index i.MM3W, vce(cluster PSUID)

reg wifebeat_index i.MM3W ln_copc, vce(cluster PSUID)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 i.RO6, vce(cluster PSUID)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 i.RO6 URBAN2011, vce(cluster PSUID)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 i.RO6 URBAN2011 i.GROUPS, vce(cluster PSUID)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 i.RO6 URBAN2011 i.GROUPS i.STATEID, vce(cluster PSUID)
*/

label variable MM3W ""  // handled by the category labels below
label variable ln_copc "Log consumption per capita"
label variable EW6 "Age"
label variable EW8 "Years of education (self)"
label variable SPED6 "Years of education (spouse)"
label variable URBAN2011 "Urban (=1)"

label define MM3W 1 "Never (ref.)" 2 "Sometimes" 3 "Regularly", replace
label values MM3W MM3W


label define RO6 0 "Married, spouse absent" 1 "Married (ref)" 3 "Widowed" 4 "Separated/divorced", replace
label values RO6 RO6


reg wifebeat_index i.MM3W, vce(cluster PSUID)
est store restricted
outreg2 using 04_regressions.tex, tex replace label ctitle(Model 1) keep (i.MM3W) addtext(No, Caste \& Religion FE, No, State FE, No)

reg wifebeat_index i.MM3W ln_copc, vce(cluster PSUID)
outreg2 using 04_regressions.tex, tex append label ctitle(Model 2) keep (i.MM3W ln_copc) addtext(No, Caste \& Religion FE, No, State FE, No)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6, vce(cluster PSUID)
outreg2 using 04_regressions.tex, tex append label ctitle(Model 3) keep (i.MM3W ln_copc 0.RO6 3.RO6 4.RO6 EW6 EW8) addtext(Caste \& Religion FE, No, State FE, No)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 URBAN2011, vce(cluster PSUID)
outreg2 using 04_regressions.tex, tex append label ctitle(Model 4) keep (i.MM3W ln_copc 0.RO6 3.RO6 4.RO6 EW6 EW8 URBAN2011) addtext(Caste \& Religion FE, No, State FE, No)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 URBAN2011 i.GROUPS, vce(cluster PSUID)
outreg2 using 04_regressions.tex, tex append label ctitle(Model 5) keep (i.MM3W ln_copc 0.RO6 3.RO6 4.RO6 EW6 EW8 URBAN2011) addtext(Caste \& Religion FE, Yes, State FE, No)

reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 URBAN2011 i.GROUPS i.STATEID, vce(cluster PSUID)
est store full
outreg2 using 04_regressions.tex, tex append label ctitle(Model 6) keep (i.MM3W ln_copc EW6 0.RO6 3.RO6 4.RO6 EW8 URBAN2011) addtext(Caste \& Religion FE, Yes, State FE, Yes)



/* HETEROGENEITY REGRESSIONS */
reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 i.GROUPS i.STATEID ///
    if URBAN2011==0, vce(cluster PSUID)

outreg2 using 05_heterogeneity.tex, tex replace label ctitle(Rural) ///
    keep(i.MM3W)
	
reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 i.GROUPS i.STATEID ///
    if URBAN2011==1, vce(cluster PSUID)

outreg2 using 05_heterogeneity.tex, tex append label ctitle(Urban) ///
    keep(i.MM3W)

	
reg wifebeat_index i.MM3W ln_copc EW6 ib1.RO6 URBAN2011 i.GROUPS i.STATEID ///
    if high_edu==0, vce(cluster PSUID)

outreg2 using 05_heterogeneity.tex, tex append label ctitle(Below median education) ///
    keep(i.MM3W)
	
	
reg wifebeat_index i.MM3W ln_copc EW6 ib1.RO6 URBAN2011 i.GROUPS i.STATEID ///
    if high_edu==1, vce(cluster PSUID)

outreg2 using 05_heterogeneity.tex, tex append label ctitle(Above median education) ///
    keep(i.MM3W)
	
	
/* ROBUSTNESS */
reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 URBAN2011 ///
    i.GROUPS i.STATEID, vce(cluster PSUID)

outreg2 using 06_robustness.tex, tex replace label ///
    ctitle(Main Specification) ///
    keep(i.MM3W)
	

	
reg wifebeat_index i.MM3W ln_copc EW6 EW8 SPED6 ///
    ib1.RO6 URBAN2011 i.GROUPS i.STATEID, ///
    vce(cluster PSUID)

outreg2 using 06_robustness.tex, tex append label ///
    ctitle(+ Spouse Education) ///
    keep(i.MM3W)
	
	

reg wifebeat_index i.MM3W ln_copc EW6 EW8 ///
    ib1.RO6 URBAN2011 i.GROUPS i.STATEID ///
    if inlist(RO6,0,1), vce(cluster PSUID)

outreg2 using 06_robustness.tex, tex append label ///
    ctitle(Currently Married Women) ///
    keep(i.MM3W)
	

/* BOUNDS */
ssc install psacalc

reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 URBAN2011 i.GROUPS i.STATEID, vce(cluster PSUID)
psacalc delta 3.MM3W, rmax(.273)
return list
psacalc delta 3.MM3W, rmax(1)
return list
psacalc beta 3.MM3W, rmax(.273)
return list
psacalc beta 3.MM3W, rmax(1)
return list

psacalc delta 3.MM3W, rmax(.4)
psacalc delta 3.MM3W, rmax(.6)
psacalc delta 3.MM3W, rmax(.8)



* 1. Run your full model
reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 ///
    URBAN2011 i.GROUPS i.STATEID, ///
    vce(cluster PSUID)

display e(N)
* 2. Store the estimation sample
gen fullsample = e(sample)

* 3. Run the unrestricted model on the SAME sample
reg wifebeat_index i.MM3W if fullsample==1

* 4. Check sample size
display e(N)


reg wifebeat_index i.MM3W ln_copc EW6 EW8 ib1.RO6 ///
    URBAN2011 i.GROUPS i.STATEID, ///
    vce(cluster PSUID)
	
psacalc delta 3.MM3W, rmax(.273)
psacalc beta 3.MM3W, rmax(.273)
