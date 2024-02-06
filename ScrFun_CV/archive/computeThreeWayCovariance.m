function threeWayCovarianceMatrix = computeThreeWayCovariance(X, Y, Z)
    % Input:
    % X, Y, Z - Input matrices where each column corresponds to a different observation

    % Step 1: Compute mean vectors
    meanX = mean(X, 2);
    meanY = mean(Y, 2);
    meanZ = mean(Z, 2);

    % Step 2: Center the matrices
    centeredX = X - meanX;
    centeredY = Y - meanY;
    centeredZ = Z - meanZ;

    % Step 3: Compute the element-wise product
    productMatrix = centeredX .* centeredY .* centeredZ;

    % Step 4: Average over observations
    n = size(X, 2); % Number of observations
    threeWayCovarianceMatrix = (1/(n-1)) * productMatrix * productMatrix';

    % Note: You can also use cov(X', Y', Z') to achieve a similar result

    % Display the result
    disp('Three-Way Covariance Matrix:');
    disp(threeWayCovarianceMatrix);
end
