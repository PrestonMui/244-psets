function [sml sml_gradient] = SML(x)
	mu_val = x(1);
	ln_sigma_val = x(2);

	global data V

	[sim_avg_cdf sim_avg_pdf sim_avg_pdf_u_im,X,Y,sigma_val] ...
	= sim_avg_vals(mu_val,ln_sigma_val);

	% Calculate the negative of the SML:
	sml = - mean(Y.*log(sim_avg_cdf) + (1-Y).*log(1 - sim_avg_cdf));

	% Calculate the gradient
	% Note: dF/dx = dF/dlog(x) * dlog(x)/dx == > dF/dlog(x) = dF/dx * x 
	if nargout > 1
	sml_gradient = -[mean((Y.*X.*sim_avg_pdf)./(sim_avg_cdf) - ...
	                ((1-Y).*X.*sim_avg_pdf)./(1-sim_avg_cdf)); ...
	                mean((Y.*X.*sim_avg_pdf_u_im)./(sim_avg_cdf) - ...
	                ((1-Y).*X.*sim_avg_pdf_u_im)./(1-sim_avg_cdf))*sigma_val];
	end

end