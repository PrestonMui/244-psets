*******************************************************************************
* Homework 3: Applied Econometrics: Problem 5: Bootstrap Probit
* Students: Christina Brown, Sam Leone, Peter McCrory, Preston Mui
*******************************************************************************
*------------------------------------------------------------------------------
* Section 1: Specify Globals, Change Directory, Import Data
*------------------------------------------------------------------------------
set more off
global main_dir = "/Users/PBM/Dropbox/Berkeley/Fall_2016/" + ///
                  "Applied_Econometrics/244-psets/ps3/code_prob5"
global data_dir = "$main_dir" + "/data"
cd $data_dir
use hw3.dta, clear
cd $main_dir
*------------------------------------------------------------------------------
* Section 2: Probit of Y on D, X, and X2
*------------------------------------------------------------------------------
mat p_value_mat = J(1,4,.)

* Probit with Clustered SEs
probit y D X X2, vce(cluster id)
test D
mat p_value_mat[1,1] = r(p)

scalar D_est = _b[D]
scalar t_est = _b[D]/_se[D]

* Probit with Boostrapped Clustered t-statistic
set seed 123
bs _b[D] _se[D], saving($data_dir/bs_cluster.dta, replace) ///
                     cluster(id) reps(1000): ///
                     probit y D X X2, vce(cluster id)

use $data_dir/bs_cluster.dta, clear
drop if _bs_1 == .
gen bs_t_est = (_bs_1 - D_est)/_bs_2

sum bs_t_est if bs_t_est < t_est

di "Symmetric Percentile t-test p-value: " %9.4f (1-r(N)/_N)
mat p_value_mat[1,2] = (1-r(N)/_N)

* Probit with Cluster-Robust Score Test
cd $data_dir
use hw3.dta, clear
probit y D X X2, vce(cluster id)
scoretest D
mat p_value_mat[1,3] = r(p)

* Probit with "Score Bootstrap"
probit y D X X2, vce(cluster id)
boottest D, seed(123) 
mat p_value_mat[1,4] = r(p)
*------------------------------------------------------------------------------
* Section 3: Export Results
*------------------------------------------------------------------------------
cd $main_dir/output
putexcel set results_table, modify
putexcel C4 = p_value_mat[1,1]
putexcel E4 = p_value_mat[1,2]
putexcel G4 = p_value_mat[1,3]
putexcel I4 = p_value_mat[1,4]





