(mbspls_1setup)=
# Data Input 

Add documentation on setup / input template script. 

```{note}
Test
```

::::{important}
:::{note}
This text is **standard** _Markdown_
:::
::::

## Input

| Fieldname                 | Input Format      |          Explanation                                          |
| --------                  | --------          |            --------                                           |
| project_name              | String            |                                                               |
| standalone_version        | Cell array        | Your matrices (double format)|
| Xs                        | Cell array (doubles)      | Your matrices (Height: 1; Width: No. of Matrices)  |
| Xs_names                  | Cell array (strings)      | Name of your matrices (Height: 1; Width: No. of Matrices)                   |
| Xs_feature_names          | Cell array (strings)      | Names of matrix features (Height: 1; Width: No. of Matrices) |

::::{important}
Make sure your Xs/Matrices do not contain any missing values. 
Make sure to either remove the missing values or impute them beforehand. 
::::

## Setup

| Fieldname                 | Input Format          |          Explanation   |
| --------                  | --------              |            --------        |
| date                      | Datefomat             | Default: 'MBSPLS_DEV_Aug2024_correctionscale_nosignflip_R2022a'                    |
| partition                 | String                | Enter the partition on your server (e.g, jobs-matlab, jobs-cpu-long)                      |
| max_sim_jobs              | Double                | Define how many parallel jobs are created (Default: 10)                   |
| parallel_jobs             | Double                | Define how many jobs run in parallel at the same time (soft threshold) (Default: 25)                   |
| mem_request               | Double                | Memory request for master and slave jobs (in GB; Default: 10)                   |
| matlab_version            | String                | Define MATLAB runtime engine (e.g, R2022a)                   |
| matlab_path               | String                | Path to MATLAB folder on your server                   |
| cache_path                | String                | Path for output text files during hyperopt, permutation, bootstrapping => generally same as scratch space                   |
| scratch_space             | String                | Path for temporary file storage (hyperopt, permutation, bootstrapping) during analysis                   |
| compilation_subpath       | String                | Default: 'for_testing'|
| mbspls_standalone_path    | String                | Path of the SPLS Toolbox|
| analysis_folder           | String                | Path to your analysis folder, (e.g., fullfile(input.path_core, 'Analysis', input.project_name,  setup.date))|
| data_folder               | String                | Path to your data folder, (e.g., fullfile(input.path_core, 'Data', input.project_name,  setup.date))|
| nodes                     | Double                | Default: 1|
| account                   | String                | Name of your account on your server|
| user                      | String                | Your username on your server|
