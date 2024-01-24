function [u1, u2, u3, v1, v2, v3, w1, w2, w3, success] = cv_spls_three_views(X, Y, Z, cu1, cu2, cu3, cv1, cv2, cv3, cw1, cw2, cw3, e, itr_lim)
    % Function for Sparse Partial Least Squares (sPLS) with three data matrices

    %--- Initial checks
    %--------------------------------------------------------------------------
    no_sparse_X1 = false;
    no_sparse_Y1 = false;
    no_sparse_Z1 = false;

    % Check if cu, cv, cw obey the limits for each dataset
    if cu1 < 1 || cu1 > sqrt(size(X, 2))
        warning('cu1 is out of interval: 1 <= cu1 <= sqrt(size(X, 2)). Not using sparsity on u1.');
        no_sparse_X1 = true;
    end

    if cu2 < 1 || cu2 > sqrt(size(X, 2))
        warning('cu2 is out of interval: 1 <= cu2 <= sqrt(size(X, 2)). Not using sparsity on u2.');
        no_sparse_X2 = true;
    end

    if cu3 < 1 || cu3 > sqrt(size(X, 2))
        warning('cu3 is out of interval: 1 <= cu3 <= sqrt(size(X, 2)). Not using sparsity on u3.');
        no_sparse_X3 = true;
    end

    if cv1 < 1 || cv1 > sqrt(size(Y, 2))
        warning('cv1 is out of interval: 1 <= cv1 <= sqrt(size(Y, 2)). Not using sparsity on v1.');
        no_sparse_Y1 = true;
    end

    if cv2 < 1 || cv2 > sqrt(size(Y, 2))
        warning('cv2 is out of interval: 1 <= cv2 <= sqrt(size(Y, 2)). Not using sparsity on v2.');
        no_sparse_Y2 = true;
    end

    if cv3 < 1 || cv3 > sqrt(size(Y, 2))
        warning('cv3 is out of interval: 1 <= cv3 <= sqrt(size(Y, 2)). Not using sparsity on v3.');
        no_sparse_Y3 = true;
    end

    if cw1 < 1 || cw1 > sqrt(size(Z, 2))
        warning('cw1 is out of interval: 1 <= cw1 <= sqrt(size(Z, 2)). Not using sparsity on w1.');
        no_sparse_Z1 = true;
    end

    if cw2 < 1 || cw2 > sqrt(size(Z, 2))
        warning('cw2 is out of interval: 1 <= cw2 <= sqrt(size(Z, 2)). Not using sparsity on w2.');
        no_sparse_Z2 = true;
    end

    if cw3 < 1 || cw3 > sqrt(size(Z, 2))
        warning('cw3 is out of interval: 1 <= cw3 <= sqrt(size(Z, 2)). Not using sparsity on w3.');
        no_sparse_Z3 = true;
    end

    % Convergence threshold
    if nargin < 13 || isempty(e)
        e = 1E-5;
    end

    % Iteration limit for calculating a vector pair
    if nargin < 14 || isempty(itr_lim)
        itr_lim = 1000;
    end

    %--- SPLS
    %--------------------------------------------------------------------------
    
    %--- Compute the covariance matrices
    C_XY = X' * Y;
    C_XZ = X' * Z;
    C_YZ = Y' * Z;

    %--- Initialise weight vectors
    u_temp = nan(size(X, 2), 2);
    v_temp = nan(size(Y, 2), 2);
    w_temp = nan(size(Z, 2), 2);

    [U, ~, V] = svd(C_XY, 0);
    u_temp(:, 1) = U(:, 1);
    u_temp(:, 1) = u_temp(:, 1) ./ norm(u_temp(:, 1)); % normalise
    v_temp(:, 1) = V(:, 1);
    v_temp(:, 1) = v_temp(:, 1) ./ norm(v_temp(:, 1)); % normalise

    clear U V

    % Main loop
    diff = 10 * e; % start the diff with a high value
    i = 0;
    success = true;

    while diff > e && success
        % Update u1
        if no_sparse_X1
            u_temp(:, 2) = C_XY * v_temp(:, 1) + C_XZ * w_temp(:, 1);
            u_temp(:, 2) = u_temp(:, 2) ./ norm(u_temp(:, 2), 2);
        else
            [u_temp(:, 2), tmp_success] = update([C_XY * v_temp(:, 1); C_XZ * w_temp(:, 1)], cu1);
            if ~tmp_success % If it was not successful, return non-sparse version
                u_temp(:, 2) = C_XY * v_temp(:, 1) + C_XZ * w_temp(:, 1);
                u_temp(:, 2) = u_temp(:, 2) ./ norm(u_temp(:, 2), 2);
            end
        end

        % Update u2
        if no_sparse_X2
            u_temp(:, 2) = C_XY * v_temp(:, 1) + C_X
