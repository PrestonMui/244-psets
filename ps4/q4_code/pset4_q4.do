*******************************************************************************
* Problem Set 4, Question 4: CRE Event Study
* Students: Christina Brown, Sam Leone, Peter McCrory, Preston Mui
*******************************************************************************
// Specify Working Directory and import the data
global pers_dir = "/Users/PBM/Dropbox/Berkeley/Fall_2016/Applied_Econometrics/"
global main = "$pers_dir/244-psets/ps4/"
cd "$main"
use curfews_class.dta, clear

*------------------------------------------------------------------------------
* Part (a): Reshape the data into wide format
*------------------------------------------------------------------------------
// Restrict the sample
keep if year >= 84 & year <= 90
// Reshape the Data
drop t
reshape wide lnarrests, i(city) j(year)

*------------------------------------------------------------------------------
* Part (b): Estimate Seven Unrestricted Cross Sectional Regressions
*------------------------------------------------------------------------------
// Dependent Variables
global depvars = "lnarrests84 lnarrests85 lnarrests86 lnarrests87 " + ///
                 "lnarrests88 lnarrests89 lnarrests90"

// Indicator for Year Enacted
replace enacted = 999 if enacted > 90
qui tab enacted, gen(enacted_)
drop enacted_6

rename (enacted_1  enacted_2  enacted_3  enacted_4  enacted_5) ///
       (enacted_85 enacted_87 enacted_88 enacted_89 enacted_90)

mvreg $depvars = enacted_*
estimates store mvreg_est

// Export the table
do q4_code/export_table4b.do

*------------------------------------------------------------------------------
* Part (c): Test the linear restrictions on {\pi_{k,t}} implied by (3)
*------------------------------------------------------------------------------
