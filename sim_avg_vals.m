function [sim_avg_cdf sim_avg_pdf sim_avg_pdf_u_im,X,Y,sigma_val] ...
	= sim_avg_vals(mu_val,ln_sigma_val)

	global data V
	% Number of Observations
	[N, ~] = size(data);

	%X and Y Values
	Y = data(:,1);
	X = data(:,2);

	% Number of simulations
	[~, M] = size(V);

	% Sigma Value
	sigma_val = exp(ln_sigma_val);

	% Value of Simulated Maximum Likelihood
	logistic_input = mu_val*ones(N,M) + sigma_val*V;
	logistic_input = bsxfun(@times,logistic_input,X);

	% Calculate the value of logistic cdf and pdf
	logist_cdf = cdf('Logistic',logistic_input,0,1);
	logist_pdf = pdf('Logistic',logistic_input,0,1);

	% Calculate the average value of the cdf and pdf across simulations.
	% This is used in the numerators and denominators of the SML and gradient
	sim_avg_cdf = mean(logist_cdf,2);
	sim_avg_pdf = mean(logist_pdf,2);
	sim_avg_pdf_u_im = mean(logist_pdf.*V,2);
end