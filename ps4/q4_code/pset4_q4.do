* To Run: do q4_code/pset4_q4.do
*******************************************************************************
* Problem Set 4, Question 4: CRE Event Study
* Students: Christina Brown, Sam Leone, Peter McCrory, Preston Mui
*******************************************************************************
qui{
// Specify Working Directory and import the data
global pers_dir = "/Users/PBM/Dropbox/Berkeley/Fall_2016/Applied_Econometrics/"
global main = "$pers_dir/244-psets/ps4/"
cd "$main"
use curfews_class.dta, clear
}
*------------------------------------------------------------------------------
* Part (a): Reshape the data into wide format
*------------------------------------------------------------------------------
qui{
// Restrict the sample
keep if year >= 84 & year <= 90
// Reshape the Data
drop t
reshape wide lnarrests, i(city) j(year)
}
*------------------------------------------------------------------------------
* Part (b): Estimate Seven Unrestricted Cross Sectional Regressions
*------------------------------------------------------------------------------
qui{
// Dependent Variables
global depvars = "lnarrests84 lnarrests85 lnarrests86 lnarrests87 " + ///
                 "lnarrests88 lnarrests89 lnarrests90"

// Indicator for Year Enacted
replace enacted = 999 if enacted > 90
qui tab enacted, gen(enacted_)
drop enacted_6

rename (enacted_1  enacted_2  enacted_3  enacted_4  enacted_5) ///
       (enacted_85 enacted_87 enacted_88 enacted_89 enacted_90)

noisily mvreg $depvars = enacted_*
estimates store mvreg_est

// Export the table
do q4_code/export_table4b.do
}
*------------------------------------------------------------------------------
* Part (c): Test the linear restrictions on {\pi_{k,t}} implied by (3)
*------------------------------------------------------------------------------
qui{
global H "85 87 88 89 90"

// First set of linear restrictions, that for all t, t' < k, pi_k,t = pi_k,t'
foreach k in $H {
	forvalues t = 84(1)90{
		forvalues t_prime = 84(1)90 {
			if `t' < `k' & `t_prime' < `k' & `t' < `t_prime'{
*------------------------------------------------------------------------------
*                Actual Test of First Set of Linear Restrictions
*------------------------------------------------------------------------------
				 test _b[lnarrests`t':enacted_`k'] = ///
				         _b[lnarrests`t_prime':enacted_`k'], `accum'
*------------------------------------------------------------------------------
	        local accum = "accum"
			}
		}
	}
}
// Second set of linear restrictions
foreach k in $H{
	foreach k_prime in $H{
		forvalues t = 84(1)90{
			forvalues s = 84(1)90{
				if `k' < `k_prime' & `t' > `s' ///
				  & `t' >= `k' & `s' >= `k' /// 
				  & `t' >= `k_prime' & `s' >= `k_prime'{
*------------------------------------------------------------------------------
*                Actual Test of Second Set of Linear Restrictions
*------------------------------------------------------------------------------
qui test _b[lnarrests`t':enacted_`k_prime'] - _b[lnarrests`t':enacted_`k'] ///
         = ///
         _b[lnarrests`s':enacted_`k_prime'] - _b[lnarrests`s':enacted_`k'] ///
         , accum
*------------------------------------------------------------------------------
				  }
			}
		}
	}
}
// Third Set of Linear Restrictions
foreach k in $H{
	foreach k_prime in $H{
		forvalues t = 84(1)90{
			forvalues s = 84(1)90{
				if `k' < `k_prime' & `t' > `s' ///
				  & `t' >= `k' & `s' >= `k' /// 
				  & `t' >= `k_prime' & `s' >= `k_prime'{
*------------------------------------------------------------------------------
*                Actual Test of Third Set of Linear Restrictions
*------------------------------------------------------------------------------
qui test ///
    _b[lnarrests`t':enacted_`k'] - _b[lnarrests`s':enacted_`k'] ///
    = ///
    _b[lnarrests`t':enacted_`k_prime'] - _b[lnarrests`s':enacted_`k_prime'] ///
    , accum
*------------------------------------------------------------------------------
			    }
			}
		}
	}
}
noisily test, accum
}






