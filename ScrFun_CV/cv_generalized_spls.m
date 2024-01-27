function [weights, covariances, success] = cv_generalized_spls(matrices, cs, gs, e, itr_lim, plotflag)
%
%   Generalized Sparse PLS algorithm
%
%   Inputs:
%       matrices - a cell array or 3D array where each element or slice represents a matrix.
%       cs       - sparsity regularization hyperparameters for each matrix.
%       gs       - factors determining the type of optimization for each matrix.
%       e        - convergence threshold.
%       itr_lim  - maximum number of iterations.
%
%   Outputs:
%       weights      - cell array containing weight vectors for each matrix.
%       covariances  - cell array containing covariance matrices between each pair of matrices.
%       success      - true if the algorithm successfully converged.
%__________________________________________________________________________


%--- Initial checks
%--------------------------------------------------------------------------
num_matrices = numel(matrices);

% Initialize cell arrays
weights = cell(num_matrices, 1);
covariances = cell(num_matrices, num_matrices);

% Initial checks
num_weights = nan(num_matrices);
no_sparse_matrix = nan(num_matrices);
failed_sparsity_weights = nan(num_matrices);
for i = 1:num_matrices
    num_weights(i) = size(matrices{i}, 2);  % Assuming all matrices have the same number of features
    if cs(i) < 1 || cs(i) > sqrt(num_weights(i))
        no_sparse_matrix(i) = true;
        failed_sparsity_weights(i) = false;
        warning(['c for matrix ' num2str(i) ' is out of interval: 1 <= c <= sqrt(number_features). Not using sparsity on this matrix.']);
    else
        no_sparse_matrix(i) = false;
    end
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
%--------------------------------------------------------------------------

weights_pairs = cell(num_matrices,1);
% Initialize weight vectors using SVD of cross-covariance matrix
for i = 1:num_matrices
    weights{i} = nan(num_weights(i), 2);

    for j = 1:num_matrices
        covariances{i, j} = matrices{i}' * matrices{j}; % why not: cov(matrices{i}, matrices{j}); ?
        [Us{i, j}, ~, Vs{i, j}] = svd(covariances{i, j}, 0);
        weights_pairs{i,j}(:,1) = Vs{i,j}(:,1);
        weights_pairs{i,j}(:,1) = weights_pairs{i,j}(:,1)./norm(weights_pairs{i,j}(:,1)); % normalise
    end


end
% Initialize weight vectors using SVD of cross-covariance matrix
for i = 1:num_matrices
    weights{i} = nan(num_weights(i), 2);

    % Initialize vs_combined as a sum of weighted columns from Vs
    %us_combined = zeros(num_weights(i), 1);
    vs_combined = zeros(num_weights(i), 1);
    for j = 1:num_matrices
        if j ~= i
            %us_combined = us_combined + gs(i, j) * Us{i, j}(:, 1);
            vs_combined = vs_combined + gs(i,j) *  weights_pairs{j,i}(:,1);
        end
    end

    % Initialize weight vectors with the combined columns
    weights{i}(:, 1) = vs_combined;
    weights{i}(:, 1) = weights{i}(:, 1) ./ norm(weights{i}(:, 1));  % normalise
end


% Main Loop
diff = 10 * e;  % start the diff with a high value
k = 0;
success = true;
figure
while diff > e && success


    if no_sparse_matrix(i) % no_sparse_X
        for i = 1:num_matrices
            weights_temp = zeros(num_weights(i),  num_matrices);
            for j = 1:num_matrices

                weights_temp(:,j) = covariances{i,j} * weights{j}(:, 1); % it is actually (:,2) when v_temp is updated

                weights_temp(:,j) = weights_temp(:,j) ./ norm(weights_temp(:,j), 2); % this in the loop or after the loop?
            end
            weights{i}(:,2) = sum(weights_temp .* gs(i, :),2);
            weights{i}(:,2) = weights{i}(:,2) ./ norm(weights{i}(:,2), 2); % this in the loop or after the loop?

        end
    else
        for i = 1:num_matrices
            weights_temp = zeros(num_weights(i),  num_matrices);
            for j = 1:num_matrices
                weights_temp(:,j) = covariances{i,j} * weights{j}(:, 1); % it is actually (:,2) when v_temp is updated
                weights_temp(:,j) = weights_temp(:,j) ./ norm(weights_temp(:,j), 2); % this in the loop or after the loop?
            end
            [weights{i}(:,2), tmp_success] = update(sum(weights_temp .* gs(i, :),2), cs(i));
            failed_sparsity_weights(i) = ~tmp_success;
            if failed_sparsity_weights(i) % If it was not successful, return non sparse version
                for j = 1:num_matrices

                    weights_temp(:,j) = covariances{i,j} * weights{j}(:, 1); % it is actually (:,2) when v_temp is updated

                    weights_temp(:,j) = weights_temp(:,j) ./ norm(weights_temp(:,j), 2); % this in the loop or after the loop?
                end
                weights{i}(:,2) = sum(weights_temp .* gs(i, :),2);
                weights{i}(:,2) = weights{i}(:,2) ./ norm(weights{i}(:,2), 2); % this in the loop or after the loop?

            end
        end
    end
    dims = cellfun(@n_nonzero_weights, weights);

    if any(dims == 0)
        error(['No weights were included in the model for matrix ' num2str(find(dims == 0)) '.']);
    end

    % Check convergence
    %weights = weights';
    diffs = cellfun(@compute_diff, weights);
    diff = min(diffs);

    % Update weights for the next iteration
    weights = cellfun(@update_weights, weights, 'UniformOutput', false);


    if k >= itr_lim
        warning('Maximum number of iterations reached.');
        success = false;
    end

% 
%     for i = 1:num_matrices
%     scatter(i, corr(X*u_temp(:,2),Y*v_temp(:,2))) 
%     hold on
%     end
    
    % colors = {'yellow', 'red', 'blue', 'green', 'orange', 'black'};
    % for i = 1:num_matrices
    %     for j = 1:num_matrices
    %         scatter(k, corr(matrices{i}*weights{i}(:,2),matrices{j}*weights{j}(:,2)), colors{i}) 
    %         hold on
    %     end
    % end

    if plotflag
        scatter(k, corr(matrices{1}*weights{1}(:,2),matrices{2}*weights{2}(:,2)), 'yellow')
        hold on
        scatter(k, corr(matrices{1}*weights{1}(:,2),matrices{3}*weights{3}(:,2)), 'red')
        hold on
        scatter(k, corr(matrices{2}*weights{2}(:,2),matrices{3}*weights{3}(:,2)), 'blue')
        hold on
    end
    
    k = k + 1;
end

for i = 1:num_matrices
    dim_str = sprintf('dim_M%d: %d    ', i, dims(i));
    if i == 1
        dims_str = dim_str;
    else
        dims_str = [dims_str, dim_str];
    end

end

fprintf('SPLS: itr: %d    diff: %.2e    %s\n', k, diff, dims_str);

%--- Add converged weight vectors to output
weights = cellfun(@format_converged_vectors, weights, 'UniformOutput', false);


end

%--- Private functions
%--------------------------------------------------------------------------
function [up, success] = update(w, c)

success = true;

%--- update values
delta = 0;
up = soft_thresh(w, delta);
up = up./norm(up,2);

%--- check if it obeys the condition. If not, find delta that does.
if norm(up, 1) > c

    delta1 = delta;
    delta2  = delta1+1.1; % delta2 must be > 1

    % get first estimate of delta2
    flag = false;
    i = 0;
    max_delta = 0;
    while ~flag
        up = soft_thresh(w, delta2);
        up = up./norm(up,2);

        if sum(abs(up)) == 0 || isnan(sum(abs(up))) % if everthing is zero, the up/|up| will be 0/0 = nan
            delta2 = delta2/1.618; % They have to be diferent, otherwise it might not converge
        elseif norm(up, 1) > c
            delta1 = delta2;
            delta2 = delta2*2; % They have to be diferent, otherwise it might not converge
        elseif norm(up, 1) <= c
            flag = true;
        end

        if delta2>max_delta, max_delta = delta2;end

        if delta2 == 0
            warning('Delta has to be zero.');
            success = false;
            break
        end
        i = i+1;
        if i>1E4
            warning('First delta estimation update did not converge.');
            delta1 = 0;
            delta2 = max_delta;
            break
        end
    end


    up = bisec(w, c, delta1, delta2);
    if isempty(up) || sum(isnan(up))>0
        warning('Delta estimation unsuccessful.')
        success = false;
    end


end

end

function out = soft_thresh(a,delta)
% Performs soft threshold (it does not normalize the output)
diff = abs(a)-delta;
diff(diff<0) = 0;
out = sign(a).*diff;

end


function out = bisec(K, c, x1,x2)
converge = false;
success = true;
tolerance = 1E-6;
while ~converge && success
    x = (x2 + x1) / 2;
    out = soft_thresh(K, x);
    out = out./norm(out,2);
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

function n_weights = n_nonzero_weights(weights)
weight_vec = weights(:,2);
n_weights = sum(~iszero(weight_vec));
end

function diff = compute_diff(weights)
diff = norm(weights(:, 2) - weights(:, 1));
end

function weights = update_weights(weights)
weights(:, 1) = weights(:, 2);
end

function weights = format_converged_vectors(weights)
weights = weights(:, end);
end