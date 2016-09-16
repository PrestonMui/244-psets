% Pset 2, question 3

% Set seed
rng(1234);
N = 500;

% Generate X and e
X = randn(N,1);
e = randn(N,1);
Y = (X + 0.1*X.^2 + e) > 0;

% b: estimate misspecified Probit by ML
beta_con = fminunc(@(b)Q(Y,X,b),[0 0])

% calculate standard errors

% fisher information
Xmatrix = [ones(N,1),X];
YHat = Xmatrix * beta_con';
fisher = zeros(2,2);
for i = 1:N
	score_i = (Y(i) * normpdf(YHat(i)) / normcdf(YHat(i)) ...
		- (1 - Y(i)) * normpdf(YHat(i)) / (1 - normcdf(YHat(i))));
	fisher = fisher + score_i * score_i * Xmatrix(i,:)' * Xmatrix(i,:);
end
fisher = fisher / N;

% average hessian
hessian = zeros(2,2);
for i = 1:N
	y = Y(i);
	phi = normpdf(YHat(i));
	Phi = normcdf(YHat(i));
	yhat = YHat(i);

	firstpart = y * phi * (yhat * Phi + phi) / Phi^2;
	secondpart = (1 - y) * phi * (phi - yhat * (1 - Phi)) / ((1 - Phi)^2);
	hessian_i = (firstpart + secondpart) * Xmatrix(i,:)' * Xmatrix(i,:);
	hessian = hessian + hessian_i;
end
hessian = hessian / N;

% report standard errors
Omega = (1/sqrt(N)) * inv(hessian) * fisher * inv(hessian);
Omega(1,1)
Omega(2,2)

% c: Score test on hypothesis that b_2 = 0
gen_resid = Y .* normpdf(YHat) ./ normcdf(YHat) - (1 - Y) .* normpdf(YHat) ./ (1 - normcdf(YHat));

	% regress generalized residuals on X^2 (no constant)
	X2 = X.^2;
	coeff = inv(X2'*X2) * X2' * gen_resid;
	sigma_2_hat = sum((gen_resid - coeff * X2).^2) / (N - 1);
	se = inv(X2' * X2) * sigma_2_hat;
	pvalue_b = 1 - normcdf(coeff / se)

% d: Calculate unconstrained model
beta_unc = fminunc(@(b)Q(Y,X,b),[0 0 0])

Xmatrix = [ones(N,1),X,X.^2];
YHat = Xmatrix * beta_unc';
fisher = zeros(3,3);
for i = 1:N
	score_i = (Y(i) * normpdf(YHat(i)) / normcdf(YHat(i)) ...
		- (1 - Y(i)) * normpdf(YHat(i)) / (1 - normcdf(YHat(i))));
	fisher = fisher + score_i * score_i * Xmatrix(i,:)' * Xmatrix(i,:);
end
fisher = fisher / N;

% average (negative) hessian
hessian = zeros(3,3);
Phi = normcdf(YHat);
phi = normpdf(YHat);

for i = 1:N
	y = Y(i);
	phi = normpdf(YHat(i));
	Phi = normcdf(YHat(i));
	yhat = YHat(i);

	firstpart = y * phi * (yhat * Phi + phi) / Phi^2;
	secondpart = (1 - y) * phi * (phi - yhat * (1 - Phi)) / ((1 - Phi)^2);
	hessian_i = (firstpart + secondpart) * Xmatrix(i,:)' * Xmatrix(i,:);
	hessian = hessian + hessian_i;
end
hessian = hessian / N;

% Wald test
	g = beta_unc(1,3);
	gprime = [0 0 1];
	wald = N * g * inv((gprime * inv(hessian) * gprime')) * g;
	pvalue_d = 1 - chi2cdf(wald,1)
	
% (1/sqrt(N)) * inv(hessian) * fisher * inv(hessian)
