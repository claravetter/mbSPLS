function [input, output] = cv_cw_mbspls_bootstrap_pruning(results_file, log_application)

load(results_file);
output.old_final_parameters = output.final_parameters;

for lv_idx =1:height(output.final_parameters)
    lv_name = ['LV_', num2str(lv_idx)];
    weights = output.final_parameters{lv_idx, matches(output.opt_parameters_names, 'weights')};
    for matrix_idx=1:numel(input.Xs)
        weight = weights{matrix_idx};
        switch log_application
            case 'CI'
                log_ci_weight = output.bootstrap_results.(lv_name).log_ci_weights{matrix_idx};
                weight(log_ci_weight) = 0;
            case 'BS'
                log_bs_weight = output.bootstrap_results.(lv_name).log_bs_weights{matrix_idx};
                weight(log_bs_weight) = 0;
        end
        weights{matrix_idx}=weight;
        output.final_parameters{lv_idx, matches(output.opt_parameters_names, 'weights')} = weights;
    end
    input.name = [input.name, 'boot_', log_application];
    boot_results_file = strrep(results_file, '.mat', ['_', log_application, '.mat']);
    try
        save(boot_results_file, 'input', 'output', 'setup');
    catch
        err
    end
end