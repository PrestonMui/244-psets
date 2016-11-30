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
}

// Fourth Set of Linear Restrictions
foreach k in $H{
	foreach k_prime in $H{
		forvalues t = 84(1)90{
			forvalues s = 84(1)90{
				if `k' < `k_prime' ///
				& `t' < `k' & `s' < `k_prime'{
					forvalues j = 0(1)6{
						local k_for = `k' + `j'
						local k_prime_for = `k_prime' + `j'
						if `k_prime_for' < 90{
*------------------------------------------------------------------------------
*                Actual Test of Fourth Set of Linear Restrictions
*------------------------------------------------------------------------------
qui test ///
    _b[lnarrests`k_for':enacted_`k'] - _b[lnarrests`t':enacted_`k'] ///
    = ///
    _b[lnarrests`k_prime_for':enacted_`k_prime'] ///
        - _b[lnarrests`s':enacted_`k_prime'] ///
    , accum
*------------------------------------------------------------------------------
						}
					}

				}
			}
		}
	}
noisily test, accum
}

*------------------------------------------------------------------------------
* Part (d): Constraint and Sureg
*------------------------------------------------------------------------------
qui do q4_code/takefromglobal

local i = 1
global drop_constraints

while _rc == 0{
	global drop_constraints $drop_constraints `r_dropped'
	local r_dropped = r(dropped_`i')
	local ++i
	capture assert "`r(dropped_`i')'" != ""
}
global drop_constraints $drop_constraints `r_dropped'

constraint drop _all

local const_num = 1

// First set of linear restrictions, that for all t, t' < k, pi_k,t = pi_k,t'
foreach k in $H {
	forvalues t = 84(1)90{
		forvalues t_prime = 84(1)90 {
			if `t' < `k' & `t_prime' < `k' & `t' < `t_prime'{
*------------------------------------------------------------------------------
*               Specify the Constraint
*------------------------------------------------------------------------------
				constraint `const_num' ///
				    [lnarrests`t']enacted_`k' = ///
				    [lnarrests`t_prime']enacted_`k'
*------------------------------------------------------------------------------
				local ++const_num
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
*                Specify the Constraint
*------------------------------------------------------------------------------
constraint `const_num' /// 
    [lnarrests`t']enacted_`k_prime' - [lnarrests`t']enacted_`k' ///
    = ///
    [lnarrests`s']enacted_`k_prime' - [lnarrests`s']enacted_`k'
*------------------------------------------------------------------------------
local ++const_num
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
*                Specify the Constraint
*------------------------------------------------------------------------------
constraint `const_num' /// 
    [lnarrests`t']enacted_`k' - [lnarrests`s']enacted_`k' ///
    = ///
    [lnarrests`t']enacted_`k_prime' - [lnarrests`s']enacted_`k_prime'
*------------------------------------------------------------------------------
local ++const_num
			    }
			}
		}
	}
}
// Fourth Set of Linear Restrictions
foreach k in $H{
	foreach k_prime in $H{
		forvalues t = 84(1)90{
			forvalues s = 84(1)90{
				if `k' < `k_prime' ///
				& `t' < `k' & `s' < `k_prime'{
					forvalues j = 0(1)6{
						local k_for = `k' + `j'
						local k_prime_for = `k_prime' + `j'
						if `k_prime_for' < 90{
*------------------------------------------------------------------------------
*                Specify the Constraint
*------------------------------------------------------------------------------
constraint `const_num' /// 
    [lnarrests`k_for']enacted_`k' - [lnarrests`t']enacted_`k' ///
    = ///
    [lnarrests`k_prime_for']enacted_`k_prime' ///
        - [lnarrests`s']enacted_`k_prime'
*------------------------------------------------------------------------------
local ++const_num
						}
					}

				}
			}
		}
	}
}

local const_num = `const_num'-1

global constraints
forvalues j = 1(1)`const_num'{
	global constraints "$constraints `j'"
}

takefromglobal constraints $drop_constraints

// Estimate the model
sureg (lnarrests84 enacted_*) (lnarrests85 enacted_*) ///
      (lnarrests86 enacted_*) (lnarrests87 enacted_*) ///
      (lnarrests88 enacted_*) (lnarrests89 enacted_*) ///
      (lnarrests90 enacted_*), ///
      constraints($constraints) 

//Recover Estimates of Delta
lincom [lnarrests85]enacted_85-[lnarrests84]enacted_85
	est store delta_0
lincom [lnarrests86]enacted_85-[lnarrests84]enacted_85
		est store delta_1
lincom [lnarrests87]enacted_85-[lnarrests84]enacted_85
		est store delta_2
lincom [lnarrests88]enacted_85-[lnarrests84]enacted_85
		est store delta_3
lincom [lnarrests89]enacted_85-[lnarrests84]enacted_85
		est store delta_4
lincom [lnarrests90]enacted_85-[lnarrests84]enacted_85
		est store delta_5





