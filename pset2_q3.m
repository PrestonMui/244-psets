% Pset 2, question 3
% Group members: Christina Brown, Sam Leone, Peter McCrory, Preston Mui

% Set seed
rng(1234);
N = 500;

% Generate X and e
X = randn(N,1);
e = randn(N,1);
Y = (X + 0.1*X.^2 + e) > 0;

% Part B: estimate misspecified Probit by ML

	beta_con = fminunc(@(b)Q(Y,X,b),[0 0]);

	% calculate standard errors

	% score outer product (meat)
	Xmatrix = [ones(N,1),X];
	LHat = Xmatrix * beta_con';
	scoreproduct = zeros(2,2);
	for i = 1:N
		score_i = (Y(i) * normpdf(LHat(i)) / normcdf(LHat(i)) ...
			- (1 - Y(i)) * normpdf(LHat(i)) / (1 - normcdf(LHat(i))));
		scoreproduct = scoreproduct + score_i * score_i * Xmatrix(i,:)' * Xmatrix(i,:);
	end
	scoreproduct = scoreproduct / N;

	% average hessian (bread)
	hessian = zeros(2,2);
	for i = 1:N
		y = Y(i);
		phi = normpdf(LHat(i));
		Phi = normcdf(LHat(i));

		firstpart = y * phi * (LHat(i) * Phi + phi) / Phi^2;
		secondpart = (1 - y) * phi * (phi - LHat(i) * (1 - Phi)) / ((1 - Phi)^2);
		hessian_i = (firstpart + secondpart) * Xmatrix(i,:)' * Xmatrix(i,:);
		hessian = hessian + hessian_i;
	end
	hessian = hessian / N;

	% report standard errors
	Omega = (1/sqrt(N)) * inv(hessian) * scoreproduct * inv(hessian);
	disp(['Coefficients a, b: ' ])
	disp(beta_con(1))
	disp(beta_con(2))
	
	disp('Standard errors a, b: ')
	disp(sqrt(Omega(1,1)))
	disp(sqrt(Omega(2,2)))
	
% c: Score test on hypothesis that b_2 = 0
% The following follows Wooldridge, pg. 570
	
	ghat = normpdf(LHat);
	Ghat = normcdf(LHat);
	
	% LHS: u_i / sqrt(G * (1 - G))
	aux_lhs = (Y - Ghat) ./ sqrt(Ghat .* (1 - Ghat));

	% RHS: g_i / sqrt(G * (1 - G)) times x and z
	aux_RHS = bsxfun(@times,ghat ./ sqrt(Ghat .* (1 - Ghat)),[Xmatrix X.^2]);

	% Regress, obtain explained sum of squares
	aux_lhs_hat = aux_RHS * inv(aux_RHS' * aux_RHS) * aux_RHS' * aux_lhs;
	ESS = (aux_lhs_hat - mean(aux_lhs))' * (aux_lhs_hat - mean(aux_lhs));

	% The LM statistic has an asymptotic distribution of Chi squared 1 under the null
	disp(['LM Statistic: ' num2str(ESS)])
	disp(['P-value: ' num2str(1-chi2cdf(ESS,1))])

% d: Unconstrained models

	% Calculate unconstrained coefficients
	beta_unc = fminunc(@(b)Q(Y,X,b),[0 0 0])
	Xmatrix = [ones(N,1),X,X.^2];
	LHat = Xmatrix * beta_unc';

	% average (negative) hessian
	hessian = zeros(3,3);
	Phi = normcdf(LHat);
	phi = normpdf(LHat);

	for i = 1:N
		y = Y(i);
		phi = normpdf(LHat(i));
		Phi = normcdf(LHat(i));

		firstpart = y * phi * (LHat(i) * Phi + phi) / Phi^2;
		secondpart = (1 - y) * phi * (phi - LHat(i) * (1 - Phi)) / ((1 - Phi)^2);
		hessian_i = (firstpart + secondpart) * Xmatrix(i,:)' * Xmatrix(i,:);
		hessian = hessian + hessian_i;
	end
	hessian = hessian / N;

% Wald test
	g = beta_unc(1,3);
	gprime = [0 0 1];
	wald = N * g * inv((gprime * (1/sqrt(N)) * inv(hessian) * gprime')) * g;
	pvalue_d = 1 - chi2cdf(wald,1);
	disp(['P-value for Wald test on b2 = 0: ', num2str(pvalue_d)])
	