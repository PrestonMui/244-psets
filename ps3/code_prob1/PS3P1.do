*Sam Leone, Christina Brown, Peter McCrory, Preston Mui
*Dr. Patrick Kline
*ECON 280B
*21 October 2016
*Problem Set #3
*Problem #1

*Set up.
cap log close
clear
cd "C:\Users\samle\Google Drive\Coursework\Kline\Problem Sets\PS3"
sysuse morg_cleaned_1980-occ.dta
append using morg_cleaned_1997-occ.dta, generate(new)
log using "PS3P1", replace

*Subproblem B

*Generate a new variable that is the log of the existing wage variable.
generate lnhr_wage = log(hr_wage)
*Restrict attention to the cleaned sample.
keep if hr_wage_sample==1
*Plot kernel density estimates of the log wage variable.
*drop if age<18

*Old code (save it, just in case):
*kdensity lnhr_wage [aweight=wgt_hrs] if new==0
*kdensity lnhr_wage [aweight=wgt_hrs] if new==1
*kdensity lnhr_wage [aweight=wgt_hrs] if new==0 & inrange(age,25,50) & black==1 & female==0
*kdensity lnhr_wage [aweight=wgt_hrs] if new==1 & inrange(age,25,50) & black==1 & female==0
*kdensity lnhr_wage [aweight=wgt_hrs] if new==0 & inrange(age,25,50) & black==0 & female==1
*kdensity lnhr_wage [aweight=wgt_hrs] if new==1 & inrange(age,25,50) & black==0 & female==1

/*

kdensity lnhr_wage [aweight=wgt_hrs], nograph generate(xa fxa)
kdensity lnhr_wage [aweight=wgt_hrs] if new==0, nograph generate(fxa0) at(xa)
kdensity lnhr_wage [aweight=wgt_hrs] if new==1, nograph generate(fxa1) at(xa)
label var fxa0 "1979"
label var fxa1 "1997"
line fxa0 fxa1 xa, sort ytitle(Kernel Density)
graph export "Kernel_Density_Full.pdf", replace

*Subproblem D

*Plot kernel density estimates of the log wage variable for subpopulations.
*Black men 25-50
kdensity lnhr_wage [aweight=wgt_hrs], nograph generate(xb fxb)
kdensity lnhr_wage [aweight=wgt_hrs] if new==0 & inrange(age,25,50) & black==1 & female==0, nograph generate(fxb0) at(xb)
kdensity lnhr_wage [aweight=wgt_hrs] if new==1 & inrange(age,25,50) & black==1 & female==0, nograph generate(fxb1) at(xb)
label var fxb0 "1979"
label var fxb1 "1997"
line fxb0 fxb1 xb, sort ytitle(Kernel Density)
graph export "Kernel_Density_Black_Men.pdf", replace
*White women 25-50
kdensity lnhr_wage [aweight=wgt_hrs], nograph generate(xc fxc)
kdensity lnhr_wage [aweight=wgt_hrs] if new==0 & inrange(age,25,50) & black==0 & female==1, nograph generate(fxc0) at(xc)
kdensity lnhr_wage [aweight=wgt_hrs] if new==1 & inrange(age,25,50) & black==0 & female==1, nograph generate(fxc1) at(xc)
label var fxc0 "1979"
label var fxc1 "1997"
line fxc0 fxc1 xc, sort ytitle(Kernel Density)
graph export "Kernel_Density_White_Women.pdf", replace

*/

*Subproblems E,F,G
*I thank Christopher Campos for help with the next section of code.

*Generate a variable for age squared.
generate age2 = age*age
*Find the propensity score with a logit.
*Use iweights since Stata 13 does not allow aweights for logit.
logit new female black other age age2 [iweight=wgt_hrs]
predict new_hat, pr
*Take the predicted value from this logit - i.e. the propensity score.
*Use it to reweight the 1997 wage distribution to have the 1979 demographic composition.
egen mean1997 = mean(new)
gen psi1997 = [(1-new_hat)/new_hat]*[mean1997/(1-mean1997)]*wgt_hrs
gen psi1979 = [new_hat/(1-new_hat)]*[(1-mean1997)/mean1997]*wgt_hrs

*Plots:



*1997 vs. 1997 using 1979 weights
*keep demographics constant as move forward in time
twoway (kdensity lnhr_wage if new==0) ///
(kdensity lnhr_wage if new==1) ///
(kdensity lnhr_wage if new==1 [aweight=psi1979] ), ///
legend(label(1 "Actual 1979") label(2 "Actual 1997") label(3 "Counterfactual 1997") ///
rows(2)) ytitle("Kernel Density") ///
title("Actual 1979 vs. Actual 1997 vs. Counterfactual 1997")
graph export Kernel_Density_1997_C1997.png, replace

*1979 vs. 1979 using 1997 weights
*keep demographics constant as move backward in time
twoway (kdensity lnhr_wage if new==0) ///
(kdensity lnhr_wage if new==1) ///
(kdensity lnhr_wage if new==0 [aweight=psi1997] ), ///
legend(label(1 "Actual 1979") label(2 "Actual 1997") label(3 "Counterfactual 1979") ///
rows(2)) ytitle("Kernel Density") ///
title("Actual 1979 vs. Actual 1979 vs. Counterfactual 1979")
graph export Kernel_Density_1979_C1979.png, replace

*1997 vs. 1979 using 1997 weights
twoway (kdensity lnhr_wage if new==1) ///
(kdensity lnhr_wage if new==0 [aweight=psi1997] ), ///
legend(label(1 "Actual 1997") label(2 "Counterfactual 1979 with 1997 Demographic Weights") ///
rows(2)) ytitle("Kernel Density") ///
title("Actual 1997 vs. Counterfactual 1979")
graph export Kernel_Density_1997_C1979.png, replace

*1979 vs. 1997 using 1979 weights
twoway (kdensity lnhr_wage if new==0) ///
(kdensity lnhr_wage if new==1 [aweight=psi1979] ), ///
legend(label(1 "Actual 1979") label(2 "Counterfactual 1997 with 1979 Demographic Weights") ///
rows(2)) ytitle("Kernel Density") ///
title("Actual 1979 vs. Counterfactual 1997")
graph export Kernel_Density_1979_C1997.png, replace



*Subproblem I

*Compare demographic characteristics (i.e. age) between actual and counterfactaul 1997.
latabstat age if new==0, stat(mean sd p10 p25 p50 p75 p90)
latabstat age [aweight=psi1979] if new==1, stat(mean sd p10 p25 p50 p75 p90)

*Subproblem J

*Do the same thing again, restricting attention to blacks.
latabstat age if new==0 & black==1, stat(mean sd p10 p25 p50 p75 p90)
latabstat age [aweight=psi1979] if new==1 & black==1, stat(mean sd p10 p25 p50 p75 p90)

*Subproblem K

*Experiment with alternative logit specifications.
*See if we can improve the results from I and J.

*First, add age cubed.

*Generate a variable for age cubed.
generate age3 = age*age*age
*Redo the logistic regression and the propensity score with age cubed.
logit new female black other age age2 age3 [iweight=wgt_hrs]
predict new_hat2, pr
gen psi1997_2 = [(1-new_hat2)/new_hat2]*[mean1997/(1-mean1997)]*wgt_hrs
gen psi1979_2 = [new_hat2/(1-new_hat2)]*[(1-mean1997)/mean1997]*wgt_hrs
*Full
latabstat age if new==0, stat(mean sd p10 p25 p50 p75 p90)
latabstat age [aweight=psi1979_2] if new==1, stat(mean sd p10 p25 p50 p75 p90)
*Black
latabstat age if new==0 & black==1, stat(mean sd p10 p25 p50 p75 p90)
latabstat age [aweight=psi1979_2] if new==1 & black==1, stat(mean sd p10 p25 p50 p75 p90)

*No improvement...
*Second, substract age squared.

*Redo the logistic regression and the propensity score without age squared.
logit new female black other age [iweight=wgt_hrs]
predict new_hat3, pr
gen psi1997_3 = [(1-new_hat3)/new_hat3]*[mean1997/(1-mean1997)]*wgt_hrs
gen psi1979_3 = [new_hat3/(1-new_hat3)]*[(1-mean1997)/mean1997]*wgt_hrs
*Full
latabstat age if new==0, stat(mean sd p10 p25 p50 p75 p90)
latabstat age [aweight=psi1979_3] if new==1, stat(mean sd p10 p25 p50 p75 p90)
*Black
latabstat age if new==0 & black==1, stat(mean sd p10 p25 p50 p75 p90)
latabstat age [aweight=psi1979_3] if new==1 & black==1, stat(mean sd p10 p25 p50 p75 p90)

*No improvement...

log close
