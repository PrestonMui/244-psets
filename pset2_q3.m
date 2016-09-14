% Pset 2, question 3

% Set seed
rng(1234);

% Generate X and e
X = randn(500,1);
e = randn(500,1);
Y = (X + 0.1*X.^2 + e) > 0;

