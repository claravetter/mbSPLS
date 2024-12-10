%% DP function to get latent scores from SPLS results
function [LS] = mb_spls_results_latent_scores(input, output, correct, boot, finalpath, flip_flag)

% load(results_file);
latent_scores_all =[]; latent_scores_names = []; RHO_all=[];

% [folderpath, ~, ~] = fileparts(results_file);
% finalpath = fullfile(folderpath, 'Tables');

Xs = input.Xs; LS = struct(); 

for lv_idx=1:height(output.final_parameters)%-1)
    for num_m=1:size(Xs,2)
        IN_matrices.train{num_m} = Xs{num_m};
        IN_matrices.test{num_m} = Xs{num_m};
        if correct && isfield(input, 'covariates')
            if lv_idx==1
                COV{num_m}.test = input.covariates{num_m};
                COV{num_m}.train = input.covariates{num_m};
            else
                COV{num_m}.train = nan(size(input.covariates,1),1);
                COV{num_m}.test = nan(size(input.covariates,1),1);
                input.correction_target(num_m) = 3;
            end
        else
            for num_m=1:size(IN_matrices.train,2)
                COV{num_m}.train = nan(size(input.Xs{num_m},1),1);
                COV{num_m}.test = nan(size(input.Xs{num_m},1),1);
            end
            input.correction_target(num_m) = 3;
        end
    end

    for num_m=1:size(IN_matrices.train,2)
        if ~isempty(input.cs_method{num_m}.correction_subgroup)
            try labels_temp = input.data_complete.foranalysis.basic{input.Y_final.Properties.RowNames, 'Labels'};
            catch
                labels_temp = input.DiagNames;
            end
            cs_method{num_m}.correction_subgroup = input.cs_method{num_m}.correction_subgroup;
            cs_method{num_m}.method = input.cs_method{num_m}.method;
            cs_method{num_m}.subgroup_train = contains(labels_temp, cs_method{num_m}.correction_subgroup);
            cs_method{num_m}.subgroup_test = contains(labels_temp, cs_method{num_m}.correction_subgroup);
        else
            cs_method{num_m}.correction_subgroup = [];
            cs_method{num_m}.method = 'mean-centering';
            cs_method{num_m}.subgroup_train = [];
            cs_method{num_m}.subgroup_test = [];
        end
    end

    [OUT_matrices] = cv_master_correctscale(IN_matrices, COV, cs_method, input.correction_target);

    log_weights = matches(output.parameters_names, 'weights');
    weights = output.final_parameters{lv_idx,log_weights};

    if flip_flag
        f_invert = @(x)(-1*x);
        for num_m = 1:length(weights)
            weights{num_m} = f_invert(weights{num_m});
        end
    end
    [RHO, lVs, weights] = cv_mbspls_projection(OUT_matrices.train, weights, input.correlation_method, input.matrix_norm);

    Xs = cv_mbspls_proj_def(Xs, weights);

    RHO_all = [RHO_all, RHO];
    latent_scores_all = [latent_scores_all, lVs];

    T = array2table(lVs);
    if isfield(input, 'final_ID')
        if isnumeric(input.final_ID)
            input.final_ID = num2cellstr(input.final_ID);
        end
        T.Properties.RowNames = input.final_ID;
    elseif isfield(input, 'final_PSN')
        T.Properties.RowNames = input.final_PSN;
    end
    T.Properties.VariableNames = input.Xs_names;

    % Save Table in Excel Sheet
    if isempty(boot)
        writetable(T, fullfile(finalpath, 'Latent_Scores.xlsx'), 'Sheet', ['LV',num2str(lv_idx)], 'WriteRowNames',true)
    else
        writetable(T, fullfile(finalpath, ['Latent_Scores_', boot, '.xlsx']),'Sheet', ['LV',num2str(lv_idx)], 'WriteRowNames',true)
    end
    LS.(['LV', num2str(lv_idx)]) = T; clear T
end
