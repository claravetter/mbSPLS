%% Simulate X and Y matrices
rng(123); % Set random seed for reproducibility

% Parameters
n_samples = 100; % Number of samples
n_features_X = 50; % Number of features in X
n_features_Y = 30; % Number of features in Y

% Simulate X and Y with mean=0 and std=1 for each feature
X = randn(n_samples, n_features_X);
Y = randn(n_samples, n_features_Y);
%%
% Scale X and Y to have mean=0 and std=1 for each feature
X = zscore(X);
Y = zscore(Y);

% Set sparsity hyperparameters
cu = 5; % Sparsity for u
cv = 5; % Sparsity for v

% Call the spls function
[u, v, success] = cv_spls(X, Y, cu, cv);
%%
% Display results
if success
    disp('Sparse PLS converged successfully.');
    
    % Display weight vectors
    disp('Weight vector u:');
    disp(u');
    
    disp('Weight vector v:');
    disp(v');
else
    disp('Sparse PLS did not converge successfully. Check warnings for details.');
end
%%
[u2, v2, success2] = cv_spls(Y, X, cu, cv);
%%
tolerance = 1e-4;
all(abs(u - v2) < tolerance)
all(abs(u2 - v) < tolerance)

% true when tolerance >= 1e-5
%%
dec = 10;

roundedu = round(u * 10^dec) / 10^dec;
roundedv2 = round(v2 * 10^dec) / 10^dec;

% Check if rounded vectors are equal
if isequal(roundedu, roundedv2)
    fprintf('The vectors are the same when rounded to %d decimals.', dec);
else
    fprintf('The vectors are different when rounded to %d decimals.', dec);
end

% vectors are the same when dec < 15

% conclusion: spls function returns the same results regardless of order of
% X and Y. This property should be maintained in multiblock spls

%%

