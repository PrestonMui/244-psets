**** Problem Set 1 Econ 244
* Christina Brown

/*Preliminaries*/
clear
set more off
cap clear matrix
set mem 100m
set matsize 800

set seed 1234

cap log close 
log using "$ps_244/log_`c(current_date)'.log", replace

******** Problem 4 ************************************************
***** Part a *****
/*
	set obs 100
	
	gen eta_c=rnormal(1,1)
	gen v_c=rnormal(0,1)
	gen clusterid=_n
	
	expand 100
	
	gen e_ic=rnormal(0,1)
	gen dstar_ic=runiform()
	gen d_ic=(dstar_ic>.5)
	gen y_ic=v_c + eta_c*d_ic + e_ic
	
	eststo clear
	
	eststo: reg y_ic d_ic
	eststo: reg y_ic d_ic, r
	eststo: reg y_ic d_ic, cl(clusterid)
	
	esttab using "$ps_244/ps2_4a_regs.tex", b label starlevels(* 0.10 ** 0.05 *** 0.01) se(5) booktabs r2 obslast ///
		title("Clustered DGP") replace mtitles("Y_ic, Regular SE" "Y_ic, Robust SE" "Y_ic, Clustered SE")

***** Part b *****

	clear
	set obs 100
	
	gen eta_c=1
	gen v_c=rnormal(0,1)
	gen clusterid=_n
	
	expand 100
	
	gen e_ic=rnormal(0,1)
	gen dstar_ic=runiform()
	gen d_ic=(dstar_ic>.5)
	gen y_ic=v_c + eta_c*d_ic + e_ic
	
	eststo clear
	
	eststo: reg y_ic d_ic
	eststo: reg y_ic d_ic, r
	eststo: reg y_ic d_ic, cl(clusterid)
	
	esttab using "$ps_244/ps2_4b_regs.tex", b label starlevels(* 0.10 ** 0.05 *** 0.01) se(5) booktabs r2 obslast ///
		title("Clustered DGP") replace mtitles("Y_ic, Regular SE" "Y_ic, Robust SE" "Y_ic, Clustered SE")
	
***** Part d *****

	set seed 1234

	cap program drop dgp
	program define dgp, rclass
		clear
		set obs 100
	
		gen eta_c=rnormal(1,1)
		gen v_c=rnormal(0,1)
		gen clusterid=_n
	
		expand 100
	
		gen e_ic=rnormal(0,1)
		gen dstar_ic=runiform()
		gen d_ic=(dstar_ic>.5)
		gen y_ic=v_c + eta_c*d_ic + e_ic
	
		reg y_ic d_ic, r
		test d_ic=1
		return scalar reject=(r(p)<.05)
	
		reg y_ic d_ic, cl(clusterid)
		test d_ic=1
		return scalar reject_cluster=(r(p)<.05)
	
	end

	simulate reject=r(reject) reject_cluster=r(reject_cluster), reps(1000): dgp
	
		eststo clear
		estpost summarize reject reject_cluster
		esttab using "$ps_244/ps2_4d_regs.tex", cells("count mean sd min max") title("Monte Carlo Simulations") replace noobs
	
***** Part e *****						*** Need to fix to have eta_c's fixed

	set seed 1234 

	clear
	set obs 100
	
	gen eta_c=rnormal(1,1)
	gen v_c=rnormal(0,1)
	gen clusterid=_n
	
	su eta_c
	global avg_eta_c=`r(mean)'
	di "`avg_eta_c'"
	
	expand 100
	
	cap program drop dgp2
	program define dgp2, rclass
	
		cap drop e_ic dstar_ic d_ic y_ic
		gen e_ic=rnormal(0,1)
		gen dstar_ic=runiform()
		gen d_ic=(dstar_ic>.5)
		gen y_ic=v_c + eta_c*d_ic + e_ic
	
		reg y_ic d_ic, r
		test d_ic=1.033752
		return scalar reject=(r(p)<.05)
	
		reg y_ic d_ic, cl(clusterid)
		test d_ic=1.033752
		return scalar reject_cluster=(r(p)<.05)
	
	end

	simulate reject=r(reject) reject_cluster=r(reject_cluster), reps(1000): dgp2

		eststo clear
		estpost summarize reject reject_cluster
		esttab using "$ps_244/ps2_4e_regs.tex", cells("count mean sd min max") title("Monte Carlo Simulations") replace noobs
*/
******** Problem 5 ************************************************
***** Part a *****
use "$ps_244/cps2000.dta" if empstat==10, clear

		drop if incwage>999000|incwage==0 //those without valid earnings
		gen wage=incwage/(uhrswork*wkswork1) //average annual hourly wages
		drop if wage<2|wage>99	//drop outliers
		gen lnwage=ln(wage) //take logs

	*construct age categories
		gen agecat=1 if age<=25
		replace agecat=2 if age>25&age<=35
		replace agecat=3 if age>35&age<=45
		replace agecat=4 if age>45&age<=55
		replace agecat=5 if age>55&age<=65
		replace agecat=6 if age>65

	*construct education categories
		gen educcat=1 if educ99>=1&educ99<=9
		replace educcat=2 if educ99==10
		replace educcat=3 if educ99>=11&educ99<=13
		replace educcat=4 if educ99>=14

		lab var agecat "Age Category"
		lab var educcat "Education Category"

		lab def agecatlbl 1 "<=25" 2 "25-35" 3 "35-45" 4 "45-55" 5 "55-65" 6 ">65"
		lab val agecat agecatlbl

		lab def educcatlbl 1 "Dropout" 2 "HS" 3 "Some College" 4 "BA+"
		lab val educcat educcatlbl

	eststo clear
	eststo: xi: reg lnwage i.agecat i.educcat sex
	
***** Part b-f *****
	bys agecat educcat sex: gen count=_N
	su lnwage
	local var `r(Var)'
	gen cell_var=`var'/count
	gen cell_var_inv=1/cell_var
	
	collapse count lnwage cell_var cell_var_inv age educ99, by(agecat educcat sex)
	
		lab var agecat "Age Category"
		lab var educcat "Education Category"
		lab val agecat agecatlbl
		lab val educcat educcatlbl
	
	eststo: xi: reg lnwage i.agecat i.educcat sex [iweight=count]
	eststo: xi: reg lnwage i.agecat i.educcat sex [iweight=cell_var_inv]
		
		esttab using "$ps_244/ps2_5a.tex", b label starlevels(* 0.10 ** 0.05 *** 0.01) se(5) booktabs r2 obslast style(tex) ///
				title("Wage Regression (Weighted)") replace mtitles("Log wage" "Log wage (weighted by cell size)" "Log wage (weighted by 1/cell var)")

***** Part h *****
	eststo clear
	eststo: xi: reg lnwage i.agecat i.educcat sex agecat#educcat agecat#sex educcat#sex [iweight=cell_var_inv]
	predict lnwage_hat
	
		esttab using "$ps_244/ps2_5h.tex", b label starlevels(* 0.10 ** 0.05 *** 0.01) se(5) booktabs r2 obslast style(tex) ///
				title("Wage Regression (Weighted)") replace mtitles("Log wage" "Log wage (weighted by cell size)" "Log wage (weighted by 1/cell var)")

	twoway (scatter lnwage agecat, msize(tiny) mcolor(red)) (scatter lnwage_hat agecat, msize(tiny) mcolor(blue)), scheme(s1mono) by(educcat sex, cols(2)) xsize(3)
	graph export "$ps_244/ps2_5j.pdf", replace
	
	
cap log close
