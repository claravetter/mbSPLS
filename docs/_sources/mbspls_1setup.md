(mbspls_1setup)=
# Data Input 

This section provides a comprehensive overview of the `input` and `setup` parameters used in the mb-sPLS toolbox. These parameters enable you to tailor the analysis workflow to your specific needs, including cross-validation settings, model optimization strategies, data scaling methods, and memory management options. Properly configuring these parameters is essential for optimizing the performance and interpretability of your mb-sPLS analysis. Each parameter is outlined with its possible options, default values, and specific role within the toolbox to assist you in the configuration process.

Once defined, the `input` and `setup` parameters are saved into a `datafile.mat` file using REPLACE?, which is then utilized in the subsequent [Model Training](mbspls_2run.md).

## Input
### Data

| Fieldname                 | Input Format      |          Explanation                                          |
| --------                  | --------          |            --------                                           |
| `project_name`              | String            | Define a project name (e.g., `input.project_name = 'YOURPROJECTNAME'`).                                                    |
| `Xs`                        | Cell array (double)      | Your matrices (e.g., `input.Xs = '{50x20 double} {50x30 double}`). The length of `input.Xs`should equal your number of matrices. |
| `Xs_names`                  | Cell array (string)      | Cell array with the names of your matrices (e.g., `input.Xs_names = {'Matrix1'}, {'Matrix2'}`. The length of `input.Xs_names` should equal the number of matrices. )                    |
| `Xs_feature_names`          | Cell array (string)      | Cell array with the names of matrix features (e.g., `input.Xs_feature_names = {1x20 cell} {1x30 cell}`. The length of `input.Xs_features_names` should equal the number of matrices. )                    |
| `covariates`                | Cell array (double)      | Your covariate(s) (vector/matrix)  |
| `covariates_names`          | Cell array (string)      | Name(s) of your covariate(s) |
| `Diag`                      | Double            | Column vector with diagnoses coded via numbers (e.g., `input.Diag = [1, 3, 2, 3, 1]`) |
| `DiagNames`                 | Cell array (string)        | Column cell array with diagnoses/labels (e.g., `input.DiagNames = {'HC', 'ROD', 'CHR', 'HC', 'ROP'}`). |
| `sites`                      | Double       | Dummy coded vector for sites. If single-site: column vector of ones. |
| `final_ID`                   | Cell array (string)   | IDs of your subjects (e.g. `input.final_ID = {'400106', '400678', '410345'})`) |
| `type_correction`          | String       | Define whether you want to correct for covariates. Options: `corrected`, `uncorrected`. |

::::{important}
Make sure your input data (i.e., Xs, covariates, sites, Diag and DiagNames) does not contain any missing values. Make sure to either remove the missing values or impute them beforehand. 
::::


### Machine Learning Framework

| Fieldname                 | Input Format      |          Explanation                                          |
| --------                  | --------          |            --------                                           |
| `framework`                                         | Double          | Cross-validation setup: `1` = Nested cross-validation, `2` = random hold-out splits, `3` = LOSOCV, `4` = random split-half. |
| `outer_folds`                                       | Double          | No. of outer folds (CV2 level); Applicable only for nested cross-validation and Random Hold-Out Splits. |
| `inner_folds`                                       | Double          | No. of inner folds (CV1 level); Applicable only for nested cross-validation and Random Hold-Out Splits. |
| `permutation_testing`                               | Double          | No. of permutations for significance testing of each LV (Default: `1000`). |
| `bootstrap_testing`                                 | Double          | No. of bootstrap samples to measure Confidence intervals and bootstrap ratios for feature weights within LV (Default: `500`). |
| `correlation_method`                                | String          | Define which correlation method is used to compute correlation between latent scores of X and Y (used for significance testing of LV). Options: `Spearman` (Default), `Pearson`. |
| `selection_train`                                   | Double          | Define how the RHO values between X and Y are collected across the cross-validation structure. Options: `1` - Within one CV2 fold (Default); `2` - Across all CV2 folds (Not recommended). |
| `selection_retrain`                                 | Double          | Define whether you want to pool data from all CV1 folds and retrain the model on these before applying on CV2 testing fold. Options: `1` = retrain on all CV1 folds (Default); `2` = no retraining, use already existing model. |
| `merge_train`                                       | String          | Define how the RHO values are collected. Options: `mean`, `median` (Default). |
| `merge_retrain`                                     | String          | Define how the best hyperparameters will be chosen on the CV1 level. Options: `best` (Default; i.e., winner takes all), `mean`, `median`, `weighted_mean`. |
| `validation_set`                                    | Boolean/Double  | Define whether to hold out a validation set. Options: `false` (Default) or a number representing a percentage of the whole sample (e.g., `25`). |
| `val_stratification`                                | Double          | Define how to extract the validation set. Options: `1`- diagnosis, `2` - sites, `3` - both. |
| `validation_train`                                  | Double          | Define how to test the model performance on the validation set. Options: `1`: Retrain optimal model on permutations of all samples except the validation set (Default), `2`: use already computed permuted performances from the CV structure |
| `alpha_value`                                       | Double          | Define overall threshold for significance (Default: `0.05`) |
| `final_merge`                                       |           |  |
| > `type`                                  | String          | Define how the final LV model will be chosen on the CV2 level. Options: `mean`, `median`, `weighted_mean`, `best` (Default). |
| > `mult_test`                             | String          | Define how correction for multiple testing across CV2 folds is done. Options: `Bonferroni`, `Sidak`, `Holm_Bonferroni`, `Benjamini_Hochberg` (Default), `Benjamini_Yekutieli`, `Storey`, `Fisher`. |
| > `significant_only`                      | String          | Only applicable if `final_merge.type` is not set to best! Defines type of CV2 fold merging. Options: `on` (use only significant folds for merging), `off` (use all folds for merging). |
| > `majority_vote`                         | String          | Only applicable if `final_merge.type` is not set to best! Options: `on` (use majority voting across folds to determine whether a value in u or v should be zero or non-zero), `off` (no majority vote, merging is done for all features). |
| `correct_limit`                                     | Double          | Define in which iteration of the process covariate correction should be done. Default: 1 (means correction is done before computing the first LV, then no more correction). |
| `statistical_testing`                               | Double          | Define how the P value is computed during permutation testing: Options: `1` (Counting method, i.e., number of instances where permuted models outperformed optimized model/number of permutations); `2` (AUC method; permuted RHO values are used to compute AUC for optimal RHO value); Note: Option 2 usually gives slightly lower P values. |
| `cs_method{1}`                               |          | |
| > `method`                               | String          | Scaling of features. Options: `mean-centering` (i.e., z- tranformation; Default), `min_max` (i.e., scaling [0-1))|
| > `correction_subgroup`                  | String          | Define whether to correct the covariates based on the betas of a subgroup, or across all individuals. For subgroup-based correction, use the label, e.g., 'HC' or 'ROD'. Otherwise, leave as an empty string: `''`. |
| `coun_ts_limit`                                     | Double          | Define after how many non-significant LVs the algorithm should stop (Default: 1; i.e., as soon as one LV is not significant, the operation ends). |
| `max_n_LVs`                                         | Double          | Maximum number of Latent Variables (LVs) to extract. Set to -1 if there is no limit. |
| `outer_permutations`                                | Double          | Define the number of permutations in the CV2 folds. Default: 1. Note that the toolbox is not optimized for permutations on folds, and permutating the folds would significantly increase computation time and is not recommended. |
| `inner_permutations`                                | Double          | Define the number of permutations in the CV1 folds. Default: 1. Similar to outer permutations, the toolbox is not optimized for permutations on folds. |
| `matrix_norm`                                       | String/Double   | Define which matrix norm is used to compute the association between latent scores of Xs (used for significance testing of LV). [If > 2 Xs:] `fro`; [If 2 Xs:]  `0` (Correlation coefficient as defined above is used). |
| `CV`                                                | Structure       | If the cross-validation structure `CV` is already defined, this input sets it directly. |
| `save_CV`                                           | Boolean/Double  | Define whether to save the cross-validation structure. Default: 0 if `CV` is provided. |
| `optimization_strategy`                             | String          | Define which search algorithm to use in order to optimize sparsity hyperparameters. Options: `grid_search` (Default), `randomized_search`. |
| If `optimization_strategy` == `grid_dynamic.onset`                                |           |  |
| `density`                                           | Cell array      | Only applicable if `optimization_strategy` is set to `grid_search`. Define the density for grid applications. Can be a single value for all Xs or specific values per matrix (e.g., `input.density = [10 10 10 10]`. |
| `grid_dynamic`                                |           |  |
| > `onset`                                | Double          | Only applicable if `optimization_strategy` is set to `grid_search`. Choose the marks for grid applications. Default: `1` (Grid is defined at the first iteration and then not changed in later iterations). |
| >` LVs`                                  | Cell Array      | Only applicable if `optimization_strategy` is set to 'grid_search'. Contains grids created using the specified density values. Is created automatically (`cellfun(@create_grid, input.density)`)|
| If `optimization_strategy` == `randomized_search`                            |            | |
| `randomized_search_params`                            |            | |
| > `randomized_search_iterations` | Double    | Only applicable if `optimization_strategy` is set to 'randomized_search'. Define the number of iterations for randomized search (Default: 1500). |
| > `randomized_search_iterations` | Double    | Only applicable if `optimization_strategy` is set to 'randomized_search'. Define the number of iterations for randomized search (Default: 1500). |
| > `seed`                     | Double          | Only applicable if `optimization_strategy` is set to 'randomized_search'. Seed for random number generator to ensure reproducibility (Default: 42). |
| > `onset`                    | Double          | Only applicable if `optimization_strategy` is set to 'randomized_search'. Define the onset for randomized search (Default: 1). |
| > `hyperparam_distributions` | Cell Array      | Only applicable if `optimization_strategy` is set to 'randomized_search'. Defines the distributions for hyperparameters using a uniform distribution. Is created automatically within the for loop. (`makedist('uniform', 1, sqrt(size(input.Xs{num_m},2)))`|

## Setup

| Fieldname                 | Input Format          |          Explanation   |
| --------                  | --------              |            --------        |
| `standalone_version`     | String         | Default: `MBSPLS_DEV_Aug2024_correctionscale_nosignflip_R2022a`. |
| `date`                   | Dateformat     | Date of the analysis or script execution. |
| `partition`              | String         | Enter the partition on your server (e.g., jobs-matlab, jobs-cpu-long). |
| `max_sim_jobs`           | Double         | Define how many parallel jobs are created. Default: 10. |
| `parallel_jobs`          | Double         | Define how many jobs run in parallel at the same time (soft threshold). Default: 25. |
| `mem_request`            | Double         | Memory request for master and slave jobs (in GB). Default: 10. |
| `matlab_version`         | String         | Define MATLAB runtime engine (e.g., `R2022a`). |
| `matlab_path`            | String         | Path to MATLAB folder on your server. |
| `cache_path`             | String         | Path for output text files during hyperopt, permutation, bootstrapping (generally the same as scratch space). |
| `scratch_space`          | String         | Path for temporary file storage (hyperopt, permutation, bootstrapping) during analysis. |
| `compilation_subpath`    | String         | Default: 'for_testing'. |
| `mbspls_standalone_path` | String         | Full path to the SPLS Toolbox. |
| `analysis_folder`        | String         | Path to your analysis folder (e.g., fullfile(input.path_core, 'Analysis', input.project_name, setup.date)). |
| `data_folder`            | String         | Path to your data folder (e.g., fullfile(input.path_core, 'Data', input.project_name, setup.date)). |
| `nodes`                  | Double         | Default: `1`. |
| `account`                | String         | Name of your account on your server. |
| `user`                   | String         | Your username on your server. |

```{note}
Test
```
