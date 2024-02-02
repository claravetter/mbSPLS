function [U, V, success] = cv_mbSPLS(X, Y, cu_multi, cv, e, itr_lim)
% Multi-Block Sparse PLS algorithm, adapted by ChatGPT from the original
% Monteiro function
% This modification includes a loop over the blocks in the provided cell
% array X and computes separate weight vectors U for each block. The
% function returns a cell array of weight vectors for each block in U.
% Ensure you have mean-centered and scaled your data appropriately before
% using this function. Adjust the parameters as needed for your specific
% use case. 
% Inputs:
% - X: Cell array of data matrices for each block (samples x features)
% - Y: Response matrix (samples x responses)
% - cu, cv: Sparsity regularization hyperparameters for X and Y
% - e: Convergence threshold
% - itr_lim: Maximum number of iterations

% Outputs:
% - U: Weight vectors for X blocks
% - V: Weight vectors for Y
% - success: Boolean indicating whether the algorithm succeeded

% Number of blocks
num_blocks = length(X);

% Check if lu and lv obey the limits
no_sparse_X = false;
no_sparse_Y = false;

if cu_multi{1} < 1 || cu_multi{1} > sqrt(size(X{1}, 2))
    warning('cu 1 is out of interval: 1 <= cu{1} <= sqrt(size(X{1},2)). Not using sparsity on X1.');
    no_sparse_X = true;
end
if cu_multi{2} < 1 || cu_multi{2} > sqrt(size(X{1}, 2))
    warning('cu 2 is out of interval: 1 <= cu{2}<= sqrt(size(X{2},2)). Not using sparsity on X2.');
    no_sparse_X = true;
end
if cv < 1 || cv > sqrt(size(Y, 2))
    warning('cv is out of interval: 1 <= cv <= sqrt(size(Y,2)). Not using sparsity on Y.');
    no_sparse_Y = true;
end

% Convergence threshold
if ~exist('e', 'var')
    e = 1E-5;
end

% Iteration limit for calculating a vector pair
if ~exist('itr_lim', 'var')
    itr_lim = 1000;
end

%--- SPLS
% Initialize weights
U = cell(1, num_blocks);
V = cell(1, num_blocks);
success = true;

for block = 1:num_blocks
    % Compute the covariance matrix
    C = X{block}' * Y; % CV: this means there is a distinction between predictors and response matrices. Is there a way to treat them all the same?
    cu = cu_multi{block};
    % Initialize weight vectors
    u_temp = nan(size(X{block}, 2), 2);
    v_temp = nan(size(Y, 2), 2);

    % Perform SVD
    [U_temp, ~, V_temp] = svd(C, 0);
    u_temp(:, 1) = U_temp(:, 1);
    u_temp(:, 1) = u_temp(:, 1) / norm(u_temp(:, 1)); % Normalize
    v_temp(:, 1) = V_temp(:, 1);
    v_temp(:, 1) = v_temp(:, 1) / norm(v_temp(:, 1)); % Normalize

    clear U_temp V_temp

    % Main Loop
    diff = 10 * e; % Start the diff with a high value
    i = 0;

    while diff > e && success
        % Compute u
        if no_sparse_X
            u_temp(:, 2) = C * v_temp(:, 1);
            u_temp(:, 2) = u_temp(:, 2) / norm(u_temp(:, 2), 2);
        else
            [u_temp(:, 2), tmp_success] = update(C * v_temp(:, 1), cu);
            if ~tmp_success
                warning(['Problem with delta estimation in u for block ' num2str(block) '. Using non-sparse version.']);
                u_temp(:, 2) = C * v_temp(:, 1);
                u_temp(:, 2) = u_temp(:, 2) / norm(u_temp(:, 2), 2);
            end
        end

        % Compute v
        if no_sparse_Y
            v_temp(:, 2) = C' * u_temp(:, 2);
            v_temp(:, 2) = v_temp(:, 2) / norm(v_temp(:, 2), 2);
        else
            [v_temp(:, 2), tmp_success] = update(C' * u_temp(:, 2), cv);
            if ~tmp_success
                warning(['Problem with delta estimation in v for block ' num2str(block) '. Using non-sparse version.']);
                v_temp(:, 2) = C' * u_temp(:, 2);
                v_temp(:, 2) = v_temp(:, 2) / norm(v_temp(:, 2), 2);
            end
        end

        % Check convergence
        diff_u = norm(u_temp(:, 2) - u_temp(:, 1));
        diff_v = norm(v_temp(:, 2) - v_temp(:, 1));

        if diff_u >= diff_v
            diff = diff_u;
        else
            diff = diff_v;
        end

        % Update u and v for the next iteration
        u_temp(:, 1) = u_temp(:, 2);
        v_temp(:, 1) = v_temp(:, 2);

        if i >= itr_lim
            warning('Maximum number of iterations reached.');
            success = false;
        end

        i = i + 1;
    end

    % Add converged weight vectors to output
    U{block} = u_temp(:, end);
    V{block} = v_temp(:, end);
end

fprintf('MB-SPLS: itr: %d    diff: %.2e\n', i, diff);
end

% Private functions
function [up, success] = update(w, c)
success = true;

% Update values
delta = 0;
up = soft_thresh(w, delta);
up = up / norm(up, 2);

% Check if it obeys the condition. If not, find delta that does.
if norm(up, 1) > c
    delta1 = delta;
    delta2 = delta1 + 1.1; % delta2 must be > 1

    % Get first estimate of delta2
    flag = false;
    i = 0;
    max_delta = 0;

    while ~flag
        up = soft_thresh(w, delta2);
        up = up / norm(up, 2);

        if sum(abs(up)) == 0 || isnan(sum(abs(up)))
            delta2 = delta2 / 1.618; % They have to be different, otherwise, it might not converge
        elseif norm(up, 1) > c
            delta1 = delta2;
            delta2 = delta2 * 2; % They have to be different, otherwise, it might not converge
        elseif norm(up, 1) <= c
            flag = true;
        end

        if delta2 > max_delta
            max_delta = delta2;
        end

        if delta2 == 0
            warning('Delta has to be zero.');
            success = false;
            break
        end

        i = i + 1;

        if i > 1E4
            warning('First delta estimation update did not converge.');
            delta1 = 0;
            delta2 = max_delta;
            break
        end
    end

    up = bisec(w, c, delta1, delta2);

    if isempty(up) || sum(isnan(up)) > 0
        warning('Delta estimation unsuccessful.')
        success = false;
    end
end
end

function out = soft_thresh(a, delta)
% Performs soft threshold (it does not normalize the output)
diff = abs(a) - delta;
diff(diff < 0) = 0;
out = sign(a) .* diff;
end

function out = bisec(K, c, x1, x2)
converge = false;
success = true;
tolerance = 1E-6;

while ~converge && success
    x = (x2 + x1) / 2;
    out = soft_thresh(K, x);
    out = out / norm(out, 2);

    if sum(abs(out)) == 0
        x2 = x;
    elseif norm(out, 1) > c
        x1 = x;
    elseif norm(out, 1) < c
        x2 = x;
    end

    diff = abs(norm(out, 1) - c);

    if diff <= tolerance
        converge = true;
    elseif isnan(sum(diff))
        success = false;
        out = nan(size(K));
    end
end
end
