**** Problem Set 3 Econ 244
* Christina Brown

/*Preliminaries*/
clear
set more off
cap clear matrix

set seed 123

cap log close 
log using "$ps_244/ps3_log_`c(current_date)'.log", replace

******** Problem 4 - Bootstrap OLS ************************************************

global ps_244 "/Users/christinabrown/Box Sync/Berkeley/Courses/Fall 2016/Econ 244 - Metrics/Problem Sets/hw3"
eststo clear
use "$ps_244/hw3.dta", clear

*** Part A: regular reg
eststo: reg y D X X2, cl(id)
scalar D_est = _b[D]
scalar t_est = _b[D]/_se[D]

*** Part C: bootstrap
bootstrap _b[D] _se[D], ///
	saving($ps_244/4c.dta, replace) reps(1000) cluster(id): ///
	reg y D X X2, cl(id)
	
eststo: bootstrap, reps(1000) cluster(id): ///
	reg y D X X2, cl(id)
	
esttab using "$ps_244/ps3_4a_c.tex", ///
	b label starlevels(* 0.10 ** 0.05 *** 0.01) ///
	se(5) booktabs r2 obslast style(tex) ///
	title("Bootstrap") replace mtitles("Standard Reg" "Bootstrap")
	
*** Part D: boostrap t-stat	
use "$ps_244/4c.dta", clear
drop if _bs_1 == .
gen bs_t_est = (_bs_1 - D_est)/_bs_2

sum bs_t_est if bs_t_est < t_est

di "p-value" %9.4f (1-r(N)/_N)

*** Part E: wild bootstrap
reg y D X X2, cl(id)
boottest D=0, weight(rademacher) boottype(wild) reps(1000) cl(id) 

	
cap log close
