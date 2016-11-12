**** Problem Set 4 Econ 244
* Christina Brown

/*Preliminaries*/
clear
set more off
cap clear matrix
set mem 100m
set matsize 800

set seed 1234

global ps_244 "/Users/christinabrown/Box Sync/Berkeley/Courses/Fall 2016/Econ 244 - Metrics/Problem Sets/hw4"

cap log close 
log using "$ps_244/log_`c(current_date)'.log", replace
use "$ps_244/curfews_class.dta", replace

******** Problem 2 ************************************************
***** Part a *****

encode city, gen(city_code)
gen E=(year==enacted)
tsset city_code t

***** Part b *****
forvalues x=1/3 {
	forvalues n=0/19 {
		gen yr_aft`x'_`n'=(t==`n')
		lab var yr_aft`x'_`n' "`n'"
	}
	forvalues n=1/22 {
		gen yr_bef`x'_`n'=(t==-`n')
		lab var yr_bef`x'_`n' "-`n'"
	}
}
	
replace yr_aft1_5=(t>=5)
replace yr_bef1_5=(t<=-5)

replace yr_aft2_10=(t>=10)
replace yr_bef2_10=(t<=-10)

replace yr_aft3_12=(t>=12)
replace yr_bef3_12=(t<=-12)

***** Part c & d *****
* 5 years
xi: reg lnarrests yr_aft1_0-yr_aft1_5 yr_bef1_2-yr_bef1_5 i.year i.city_code , r cl(city_code)

coefplot, yline(0) xline(4.5) vertical title("Coefficients and 95% CI before and after the policy") ///
		keep(yr_bef1_5 yr_bef1_4 yr_bef1_3 yr_bef1_2 yr_aft1_0 yr_aft1_1 yr_aft1_2 yr_aft1_3 yr_aft1_4 yr_aft1_5) ///
		order(yr_bef1_5 yr_bef1_4 yr_bef1_3 yr_bef1_2 yr_aft1_0 yr_aft1_1 yr_aft1_2 yr_aft1_3 yr_aft1_4 yr_aft1_5)
graph export "$ps_244/input/coef_plot_5year.pdf", replace

* 10 years
eststo clear	
eststo, title("Log Arrests"): xi: reg lnarrests yr_aft2_0-yr_aft2_10 yr_bef2_2-yr_bef2_10 i.year i.city_code , r cl(city_code)

coefplot, yline(0) xline(9.5) vertical title("Coefficients and 95% CI before and after the policy") ///
		keep(yr_bef2_10 yr_bef2_9 yr_bef2_8 yr_bef2_7 yr_bef2_6 yr_bef2_5 yr_bef2_4 yr_bef2_3 yr_bef2_2 yr_aft2_0 yr_aft2_1 yr_aft2_2 yr_aft2_3 yr_aft2_4 yr_aft2_5 yr_aft2_6 yr_aft2_7 yr_aft2_8 yr_aft2_9 yr_aft2_10) ///
		order(yr_bef2_10 yr_bef2_9 yr_bef2_8 yr_bef2_7 yr_bef2_6 yr_bef2_5 yr_bef2_4 yr_bef2_3 yr_bef2_2 yr_aft2_0 yr_aft2_1 yr_aft2_2 yr_aft2_3 yr_aft2_4 yr_aft2_5 yr_aft2_6 yr_aft2_7 yr_aft2_8 yr_aft2_9 yr_aft2_10)
graph export "$ps_244/input/coef_plot_10year.pdf", replace

* 12 years		
xi: reg lnarrests yr_aft3_0-yr_aft3_12 yr_bef3_2-yr_bef3_12 i.year i.city_code , r cl(city_code)
		
coefplot, yline(0) xline(11.5) vertical title("Coefficients and 95% CI before and after the policy") ///
		keep(yr_bef3_12 yr_bef3_11 yr_bef3_10 yr_bef3_9 yr_bef3_8 yr_bef3_7 yr_bef3_6 yr_bef3_5 yr_bef3_4 yr_bef3_3 yr_bef3_2 yr_aft3_0 yr_aft3_1 yr_aft3_2 yr_aft3_3 yr_aft3_4 yr_aft3_5 yr_aft3_6 yr_aft3_7 yr_aft3_8 yr_aft3_9 yr_aft3_10 yr_aft3_11 yr_aft3_12) ///
		order(yr_bef3_12 yr_bef3_11 yr_bef3_10 yr_bef3_9 yr_bef3_8 yr_bef3_7 yr_bef3_6 yr_bef3_5 yr_bef3_4 yr_bef3_3 yr_bef3_2 yr_aft3_0 yr_aft3_1 yr_aft3_2 yr_aft3_3 yr_aft3_4 yr_aft3_5 yr_aft3_6 yr_aft3_7 yr_aft3_8 yr_aft3_9 yr_aft3_10 yr_aft3_11 yr_aft3_12)
graph export "$ps_244/input/coef_plot_12year.pdf", replace		
	
	
****** Part e******	
eststo, title("Log Arrests"): xi: reg lnarrests yr_aft2_0-yr_aft2_10 yr_bef2_2-yr_bef2_10 i.year i.city_code i.city_code*t, r cl(city_code)
		esttab using "$ps_244/input/ps4_q2b.tex", ///
				b label starlevels(* 0.10 ** 0.05 *** 0.01) se(5) booktabs r2 obslast style(tex) ///
				mtitles title("Question 2b and 2e" \label{q2b}) replace 

coefplot, yline(0) xline(9.5) vertical title("Coefficients and 95% CI before and after the policy") ///
		keep(yr_bef2_10 yr_bef2_9 yr_bef2_8 yr_bef2_7 yr_bef2_6 yr_bef2_5 yr_bef2_4 yr_bef2_3 yr_bef2_2 yr_aft2_0 yr_aft2_1 yr_aft2_2 yr_aft2_3 yr_aft2_4 yr_aft2_5 yr_aft2_6 yr_aft2_7 yr_aft2_8 yr_aft2_9 yr_aft2_10) ///
		order(yr_bef2_10 yr_bef2_9 yr_bef2_8 yr_bef2_7 yr_bef2_6 yr_bef2_5 yr_bef2_4 yr_bef2_3 yr_bef2_2 yr_aft2_0 yr_aft2_1 yr_aft2_2 yr_aft2_3 yr_aft2_4 yr_aft2_5 yr_aft2_6 yr_aft2_7 yr_aft2_8 yr_aft2_9 yr_aft2_10)
graph export "$ps_244/input/coef_plot_10year_trend.pdf", replace


cap log close
