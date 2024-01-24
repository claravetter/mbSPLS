function [u, v, w, success] = cv_multiblock_spls(X, Y, Z, cu, cv, cw, e, itr_lim)
%
%   Sparse PLS algorithm for three datasets.
%
%   Inputs: X, Y, Z - data matrices in the form: samples x features. These
%                    should have each feature with mean = 0 and std = 1;
%
%           cu, cv, cw - sparsity regularization hyperparameters, must be
%                        between 1 and sqrt(number_features). The lower it is,
%                        the sparser the solution. If it is outside this range,
%                        no sparsity will be applied in the corresponding view.
%
%           e        - convergence threshold (see the code for info on how it
%                      works). Default: 1E-5
%
%           itr_lim  - maximum number of iterations (it gives a warning
%                      if it does not converge). Default: 1000
%
%   Outputs: u, v, w - weight vectors for X, Y, and Z, respectively
%
%            success - will return "false" if something went wrong during
%                      the weight vector computation
%
%__________________________________________________________________________


%--- Initial checks
%--------------------------------------------------------------------------
no_sparse_X = false;
no_sparse_Y = false;
no_sparse_Z = false;

% Check if cu, cv, cw obey the limits
if cu < 1 || cu > sqrt(size(X, 2))
    warning('cu is out of interval: 1 <= cu <= sqrt(size(X, 2)). Not using sparsity on u.');
    no_sparse_X = true;
end

if cv < 1 || cv > sqrt(size(Y, 2))
    warning('cv is out of interval: 1 <= cv <= sqrt(size(Y, 2)). Not using sparsity on v.');
    no_sparse_Y = true;
end

if cw < 1 || cw > sqrt(size(Z, 2))
    warning('cw is out of interval: 1 <= cw <= sqrt(size(Z, 2)). Not using sparsity on w.');
    no_sparse_Z = true;
end

% Convergence threshold
if nargin < 7 || isempty(e)
    e = 1E-5;
end

% Iteration limit for calculating a vector pair
if nargin < 8 || isempty(itr_lim)
    itr_lim = 1000;
end

%--- SPLS
%--------------------------------------------------------------------------

%--- Compute the covariance matrices
C_XY = X' * Y;
C_XZ = X' * Z;
C_YZ = Y' * Z;

%--- Initialise weight vectors
u_temp1 = nan(size(X, 2), 2);
v_temp1 = nan(size(Y, 2), 2);
w_temp1 = nan(size(Z, 2), 2);
u_temp2 = nan(size(X, 2), 2);
v_temp2 = nan(size(Y, 2), 2);
w_temp2 = nan(size(Z, 2), 2);

[U1, ~, V1] = svd(C_XY, 0); % singular value decomposition 
u_temp1(:, 1) = U1(:, 1);
u_temp1(:, 1) = u_temp1(:, 1) ./ norm(u_temp1(:, 1)); % normalise
v_temp1(:, 1) = V1(:, 1);
v_temp1(:, 1) = v_temp1(:, 1) ./ norm(v_temp1(:, 1)); % normalise

[U2, ~, W1] = svd(C_XZ, 0); % singular value decomposition 
u_temp2(:, 1) = U2(:, 1);
u_temp2(:, 1) = u_temp2(:, 1) ./ norm(u_temp2(:, 1)); % normalise
w_temp1(:, 1) = W1(:, 1);
w_temp1(:, 1) = w_temp1(:, 1) ./ norm(w_temp1(:, 1)); % normalise

[V2, ~, W2] = svd(C_YZ, 0); % singular value decomposition 
v_temp2(:, 1) = V2(:, 1);
v_temp2(:, 1) = v_temp2(:, 1) ./ norm(v_temp2(:, 1)); % normalise
w_temp2(:, 1) = W2(:, 1);
w_temp2(:, 1) = w_temp2(:, 1) ./ norm(w_temp2(:, 1)); % normalise



alpha = 0.5; % Treat datasets equally
u_temp = alpha * u_temp1(:, 1) + (1 - alpha) * u_temp2(:, 1);
v_temp = alpha * v_temp1(:, 1) + (1 - alpha) * v_temp2(:, 1);
w_temp = alpha * w_temp1(:, 1) + (1 - alpha) * w_temp2(:, 1);

clear U1 V1 W1 U2 V2 W2 u_temp1 u_temp2 v_temp1 v_temp2 w_temp1 w_temp2
% Main Loop
diff = 10 * e; % start the diff with a high value
i = 0;
success = true;
while diff > e && success
    % Compute u
    if no_sparse_X
        u_temp(:, 2) = C_XY * v_temp(:, 1) + C_XZ * w_temp(:, 1);
        u_temp(:, 2) = u_temp(:, 2) ./ norm(u_temp(:, 2), 2);
    else
        % Combine information from Y and Z with weights v_temp(:, 1) and w_temp(:, 1)
        joint_info = C_XY * v_temp(:, 1) + C_XZ * w_temp(:, 1);
 
        % Update u_temp(:, 2) using the joint information and enforce sparsity
        [u_temp(:, 2), tmp_success] = update(joint_info, cu);

        if ~tmp_success % If it was not successful, return non-sparse version
            u_temp(:, 2) = joint_info;
            u_temp(:, 2) = u_temp(:, 2) ./ norm(u_temp(:, 2), 2);
        end
    end
    dim_u = sum(u_temp(:, 2) ~= 0);
    if ~dim_u
        error('No weights were included in the model for u.');
    end

    % Compute v
    if no_sparse_Y
        v_temp(:, 2) = C_XY' * u_temp(:, 2) + C_YZ * w_temp(:, 1);
        v_temp(:, 2) = v_temp(:, 2) ./ norm(v_temp(:, 2), 2);
    else
        % Combine information from X and Z with weights u_temp(:, 2) and w_temp(:, 1)
        joint_info = C_XY' * u_temp(:, 2) + C_YZ * w_temp(:, 1);

        % Update v_temp(:, 2) using the joint information and enforce sparsity
        [v_temp(:, 2), tmp_success] = update(joint_info, cv);

        if ~tmp_success % If it was not successful, return non-sparse version
            v_temp(:, 2) = joint_info;
            v_temp(:, 2) = v_temp(:, 2) ./ norm(v_temp(:, 2), 2);
        end
    end
    dim_v = sum(v_temp(:, 2) ~= 0);
    if ~dim_v
        error('No weights were included in the model for v.');
    end

    % Compute w
    if no_sparse_Z
        w_temp(:, 2) = C_XZ' * u_temp(:, 2) + C_YZ' * v_temp(:, 2);
        w_temp(:, 2) = w_temp(:, 2) ./ norm(w_temp(:, 2), 2);
    else
        % Combine information from X and Y with weights u_temp(:, 2) and v_temp(:, 2)
        joint_info = C_XZ' * u_temp(:, 2) + C_YZ' * v_temp(:, 2);

        % Update w_temp(:, 2) using the joint information and enforce sparsity
        [w_temp(:, 2), tmp_success] = update(joint_info, cw);

        if ~tmp_success % If it was not successful, return non-sparse version
            w_temp(:, 2) = joint_info;
            w_temp(:, 2) = w_temp(:, 2) ./ norm(w_temp(:, 2), 2);
        end
    end
    dim_w = sum(w_temp(:, 2) ~= 0);
    if ~dim_w
        error('No weights were included in the model for w.');
    end

    % Check convergence
    diff_u = norm(u_temp(:, 2) - u_temp(:, 1));
    diff_v = norm(v_temp(:, 2) - v_temp(:, 1));
    diff_w = norm(w_temp(:, 2) - w_temp(:, 1));
    max_diff = max([diff_u, diff_v, diff_w]);
    diff = max_diff;

    % update u, v, and w for the next iteration
    u_temp(:, 1) = u_temp(:, 2);
    v_temp(:, 1) = v_temp(:, 2);
    w_temp(:, 1) = w_temp(:, 2);

    if i >= itr_lim
        warning('Maximum number of iterations reached.');
        success = false;
    end

    i = i + 1;
end

fprintf('SPLS: itr: %d    diff: %.2e    dim_u: %d    dim_v: %d    dim_w: %d\n', i, diff, dim_u, dim_v, dim_w);

% Add converged weight vectors to output
u = u_temp(:, end);
v = v_temp(:, end);
w = w_temp(:, end);

end


%--- Private functions
%--------------------------------------------------------------------------
function [up, success] = update(w, c)

success = true;

% Update values
delta = 0;
up = soft_thresh(w, delta);
up = up ./ norm(up, 2);

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
        up = up ./ norm(up, 2);

        if all(up == 0) || any(isnan(up)) % if everything is zero or contains NaN, the up/|up| will be 0/0 = nan
            delta2 = delta2 / 1.618; % They have to be different; otherwise, it might not converge
        elseif norm(up, 1) > c
            delta1 = delta2;
            delta2 = delta2 * 2; % They have to be different; otherwise, it might not converge
        elseif norm(up, 1) <= c
            flag = true;
        end

        if delta2 > max_delta, max_delta = delta2; end

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
    if isempty(up) || any(isnan(up))
        warning('Delta estimation unsuccessful.')
        success = false;
    end
end

end



function out = soft_thresh(a, delta)
% Performs soft thresholding (it does not normalize the output)
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
    out = out ./ norm(out, 2);

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
