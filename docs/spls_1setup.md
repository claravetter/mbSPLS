(spls_1setup)=
# Data Input 

This section provides a comprehensive overview of the `input` and `setup` parameters used in the sPLS toolbox. These parameters enable you to tailor the analysis workflow to your specific needs, including cross-validation settings, model optimization strategies, data scaling methods, and memory management options. Properly configuring these parameters is essential for optimizing the performance and interpretability of your mb-sPLS analysis. Each parameter is outlined with its possible options, default values, and specific role within the toolbox to assist you in the configuration process.

Once defined, the `input` and `setup` parameters are saved into a `datafile.mat` file using `<placeholder>`, which is then utilized in the subsequent [Model Training](spls_2run.md).

## Input
### Data

| Fieldname                 | Input Format      |          Explanation                                          |
| --------                  | --------          |            --------                                           |
| `project_name`              | String          | Define a project name (e.g., `input.project_name = 'YOURPROJECTNAME'`).                                             |
| `X`                        | Double           | Define your 1st matrix (e.g., `input.X = '300x20 double'`). |
| `X_names`                  | Cell array (string)      | Define the names of your features in `input.X` (e.g., `input.X_names = '1x20 cell'`) (or leave empty).|
| `Y`                        | Cell array (double)      | Define your 2nd matrix (e.g., `input.Y = '300x15 double'`). |
| `Y_names`                  | Cell array (string)      | Define the names of your features in `input.Y` (e.g., `input.Y_names = '1x15 cell'`) (or leave empty).|
| `type_correction`          | String       | Define whether you want to correct for covariates. Options: `corrected`, `uncorrected`. |
| `covariates`                | Double      | If you would like to correct for covariates, define your covariate(s) (vector/matrix) (e.g., `input.covariates = 300x3 double`) or leave empty if you don't have any covariates.|
| `covariates_names`          | Cell array (string)      | If you would like to correct for covariates, define the name(s) of your covariate(s) (e.g., `input.covariate_names = {'PC1'}, {'PC2'}, {'PC3'}`). If you would like to correct for e.g., sites, you would have to create a dummy-coded vector (0,1) for each site, so that the number of columns in your covariate matrix equals the number of sites, you would like to correct for.|
| `correction_target`          | String       | Define which matrix you would like to remove the covariate effects from. Options: `1`- X, `2`- Y, `3`- X and Y. |
| `Diag`                      | Double            | Define a column vector with diagnoses/labels coded via numbers (e.g., `input.Diag = [1, 3, 2, 3, 1, ...]`). It should have the same length as the number of participants.|
| `DiagNames`                 | Cell array (string)        | Column cell array with diagnoses/labels (e.g., `input.DiagNames = {'HC', 'ROD', 'CHR', 'HC', 'ROP', ...}`).|
| `sites`                      | Double       | Dummy coded vector for sites. If single-site: column vector of ones. (e.g., `input.Diag = [1, 3, 2, 3, 1, ...]`). It should have the same length as the number of participants. |
| `sites_names`                      | Cell array (string)       | Define the name(s) of your site(s) (e.g., `input.sites_names = {'LMU', 'LMU', 'Yale', 'LMU', ... }`). It should have the same length as the number of participants.|
| `final_ID`                   | Cell array (string)   | Define the IDs of your subjects (e.g. `input.final_ID = {'400106', '400678', '410345', ...})`). It should have the same length as the number of participants.|

::::{important}
Make sure your input data (i.e., `input.X`, `input.Y`, `input.covariates`, `input.sites`, `input.Diag` and `input.DiagNames`) does not contain any missing values. Make sure to either remove the missing values or impute them beforehand. 

If `input.X` and `input.Y` do not have the same number of features, `input.X` has to be the matrix that has more features.
::::



### Machine Learning Framework

| Fieldname                 | Input Format      |          Explanation                                          |
| --------                  | --------          |            --------                                           |
| `framework`                                         | Double          | Cross-validation setup: `1` = Nested cross-validation, `2` = random hold-out splits, `3` = LOSOCV, `4` = random split-half. |
| `density`                                       | Double          | Defines the number of data points which are tested during the grid (Range: 0 to 100) (e.g., `input.density = 20` means that between start and end point, 20 equidistant values are tested for the hyperparameter.)|
| `outer_folds`                                       | Double          | No. of outer folds (CV2 level); Applicable only for nested cross-validation and Random Hold-Out Splits. (Default: `5`, `10`)|
| `inner_folds`                                       | Double          | No. of inner folds (CV1 level); Applicable only for nested cross-validation and Random Hold-Out Splits. (Default: `5`, `10`)|
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
| > `method`                               | String          | Scaling of features. Options: `mean-centering` (i.e., z- tranformation; Default), `min_max` (i.e., scaling [0-1])|
| > `correction_subgroup`                  | String          | Define whether to correct the covariates based on the betas of a subgroup, or across all individuals. For subgroup-based correction, use the label, e.g., `'HC'` or `'ROD'`. Otherwise, leave as an empty string: `''`. |
| `coun_ts_limit`                                     | Double          | Define after how many non-significant LVs the algorithm should stop (Default: `1`; i.e., as soon as one LV is not significant, the operation ends). |
| `outer_permutations`                                | Double          | Define the number of permutations in the CV2 folds (Default: `1`). Note that the toolbox is not yet optimized for permutations on folds, and permutating the folds would significantly increase computation time and is not recommended. |
| `inner_permutations`                                | Double          | Define the number of permutations in the CV1 folds (Default: `1`). Similar to outer permutations, the toolbox is not yet optimized for permutations on folds. |
| `grid_dynamic`                                |           |  |
| > `onset`                                | Double          | Choose the marks for grid applications. Default: `1` (Grid is defined at the first iteration and then not changed in later iterations). |
| >` LV_1.x`                                  | Struct      | `'start'` defines the lower limit of the hyperparameter search (i.e., 1 means start is at value 1, 10 means it starts at the lower 10 percentile of the grid, etc.) (Default: `1`); `'end'` defines the upper limit of the hyperparameter search (i.e., 0 means all the way to the end, 10 means to stop at the upper 10 percentile, etc.) (Default: `0`)|
| >` LV_1.y`                                  | Struct      | `'start'` defines the lower limit of the hyperparameter search (i.e., 1 means start is at value 1, 10 means it starts at the lower 10 percentile of the grid, etc.); `'end'` defines the upper limit of the hyperparameter search (i.e., 0 means all the way to the end, 10 means to stop at the upper 10 percentile, etc.)|

## Setup

| Fieldname                 | Input Format          |          Explanation   |
| --------                  | --------              |            --------        |
| `date`                    | Dateformat     | Date of the analysis or script execution. |
| `spls_standalone_path`    | String         | Enter the name of the spls toolbox version (e.g., `setup.spls_standalone_path = '/data/core-psy-pronia/opt/SPLS_Toolbox_Dev_2023_CORE'`). |
| `analysis_folder`        | String         | Define the path to your analysis folder (e.g., `setup.analysis_folder = '/data/core-psy-archive/projects/YourProjectFolder'`). |
| `partition`              | String         | Enter the partition on your server (e.g., `setup.partition = 'jobs-cpu-long'`). |
| `max_sim_jobs`           | Double         | Define how many parallel jobs are created (Default: `10`). |
| `parallel_jobs`          | Double         | Define how many jobs run in parallel at the same time (soft threshold) (Default: `25`). |
| `mem_request`            | Double         | Define the memory request for master and slave jobs (in GB) (Default: `10`). |
| `matlab_version`         | String         | Define MATLAB runtime engine (e.g., `R2022a`). |
| `matlab_path`            | String         | Define path to MATLAB folder on your server (e.g., `input.matlab_path = '/data/core-psy-pronia/opt/matlab/v912'`).|
| `cache_path`             | String         | Path for output text files during hyperopt, permutation, bootstrapping (generally the same as scratch space) (e.g., `setup.cache_path = '/data/core-psy-pronia/opt/temp/YourUsername'`) |
| `scratch_space`          | String         | Path for temporary file storage (hyperopt, permutation, bootstrapping) during analysis.  (e.g., `setup.scratch_path = '/data/core-psy-pronia/opt/temp/YourUsername'`) |
| `compilation_subpath`    | String         | Default: `'for_testing'`. |
| `nodes`                  | Double         | Default: `1`. |
| `queue_name`             | String         | Default: `''`; Leave empty for now. |
| `account`                | String         | Name of your account on your server. (e.g., `input.account = 'core-psy'`)|
| `user`                   | String         | Your username on your server (e.g., `input.user = 'clweyer'`)|

