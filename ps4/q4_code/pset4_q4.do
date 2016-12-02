* To Run: do q4_code/pset4_q4.do
*******************************************************************************
* Problem Set 4, Question 4: CRE Event Study
* Students: Christina Brown, Sam Leone, Peter McCrory, Preston Mui
*******************************************************************************
qui{
set more off
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
}

*------------------------------------------------------------------------------
* Part (d): Constraint and Sureg
*------------------------------------------------------------------------------
qui{
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
estimates store constrained_est

esttab constrained_est

// This file exports the table produced in part (b) of pset4_q4.do
esttab constrained_est using input/ps4_q4d.tex, ///
    unstack se replace nonum ///
    cells(b(star fmt(2)) se(par fmt(2))) ///
    eqlabels("1984" "1985" "1986" "1987" "1988" "1989" "1990") ///
    mlabels("Log of Arrests Made in", span  ///
                                      prefix(\multicolumn{@span}{c}{) ///
                                      suffix(})) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    varlabels( _cons "Year Intercept" ///
        enacted_84 "Enacted in 1984" /// 
        enacted_85 "Enacted in 1985" /// 
        enacted_86 "Enacted in 1986" /// 
        enacted_87 "Enacted in 1987" /// 
        enacted_88 "Enacted in 1988" /// 
        enacted_89 "Enacted in 1989" /// 
        enacted_90 "Enacted in 1990")

//Recover Estimates of Delta
matrix deltas = J(6,2,.)
forvalues i = 0(1)5{
	local t = 85 + `i'
	lincom [lnarrests`t']enacted_85-[lnarrests84]enacted_85
	
	matrix deltas[`i'+1,1] = r(estimate)
	matrix deltas[`i'+1,2] = r(se)
}
// Export the table
esttab matrix(deltas,fmt(3)) using input/ps4_q4d_lincoms.tex, ///
	mlabel(,none) collabels("Estimate" "S.E.") tex replace ///
	substitute(r1 "\$ \delta_0 = \pi_{85,85} - \pi_{85,84} \$" ///
	           r2 "\$ \delta_1 = \pi_{85,86} - \pi_{85,84} \$" ///
	           r3 "\$ \delta_2 = \pi_{85,87} - \pi_{85,84} \$" ///
	           r4 "\$ \delta_3 = \pi_{85,88} - \pi_{85,84} \$" ///
	           r5 "\$ \delta_4 = \pi_{85,89} - \pi_{85,84} \$" ///
	           r6 "\$ \delta_5 = \pi_{85,90} - \pi_{85,84} \$")
}



