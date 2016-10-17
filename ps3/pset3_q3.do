* Problem set 3, question 3: control functions vs ivs
clear
set more off
set seed 12345
matrix drop _all
set matsize 800

capture program drop getestimates

program getestimates, rclass
	version 13.0
	
	args gamma

	preserve

	matrix V = (1, 0, 0 \ 0, 1, 0.2 \ 0, 0.2, 1)
	qui drawnorm Z epsilon v, clear double n(1000) cov(V)

	gen X = 0.0 + `gamma' * Z + v
	gen X2 = X^2
	gen Y = 0.0 + X + X2 + epsilon

	* Get 2SLS estimates
	gen Z2 = Z^2
	qui reg X Z Z2
	qui predict XHat
	qui reg X2 Z Z2
	qui predict X2Hat

	qui reg Y XHat X2Hat
	local beta1_2sls = _b[XHat]
	local beta2_2sls = _b[X2Hat]

	* Get control function estimates
	qui reg X Z
	qui predict vHat, res
	qui reg Y X X2 vHat

	local beta1_cf = _b[X]
	local beta2_cf = _b[X2]

	return scalar beta1_2sls = `beta1_2sls'
	return scalar beta2_2sls = `beta2_2sls'
	return scalar beta1_cf = `beta1_cf'
	return scalar beta2_cf = `beta2_cf'

	restore

end

set obs 3000
gen gamma = .
gen beta1_2sls = .
gen beta2_2sls = .
gen beta1_cf = .
gen beta2_cf = .

forv i = 1/1000 {
	disp `i'
	getestimates 0.1
	qui replace gamma = 0.1 if _n==`i'
	qui replace beta1_2sls = `r(beta1_2sls)' if _n==`i'
	qui replace beta2_2sls = `r(beta2_2sls)' if _n==`i'
	qui replace beta1_cf = `r(beta1_cf)' if _n==`i'
	qui replace beta2_cf = `r(beta2_cf)' if _n==`i'
}

forv i = 1001/2000 {
	disp `i'
	getestimates 0.2
	qui replace gamma = 0.2 if _n==`i'
	qui replace beta1_2sls = `r(beta1_2sls)' if _n==`i'
	qui replace beta2_2sls = `r(beta2_2sls)' if _n==`i'
	qui replace beta1_cf = `r(beta1_cf)' if _n==`i'
	qui replace beta2_cf = `r(beta2_cf)' if _n==`i'
}

forv i = 2001/3000 {
	disp `i'
	getestimates 0.3
	qui replace gamma = 0.3 if _n==`i'
	qui replace beta1_2sls = `r(beta1_2sls)' if _n==`i'
	qui replace beta2_2sls = `r(beta2_2sls)' if _n==`i'
	qui replace beta1_cf = `r(beta1_cf)' if _n==`i'
	qui replace beta2_cf = `r(beta2_cf)' if _n==`i'
}


