% Function that calculates the negative log-likelihood of data input

function negLogLikelihood = Q(Y,X,b)

	N = length(X);
	K = length(b);

	YHat = zeros(length(X),1);
	for k = 1:K
		YHat = YHat + X.^(k - 1) * b(k);
	end

	negLogLikelihood = - sum( ...
		Y.*log(normcdf(YHat)) + (1-Y).*log((1 - normcdf(YHat))));

end