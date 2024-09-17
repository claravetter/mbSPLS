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
| standalone_version        | String            | Default: 'MBSPLS_DEV_Aug2024_correctionscale_nosignflip_R2022a'                    |

## Setup

| Fieldname                 | Input Format          |          Explanation   |
| --------                  | --------              |            --------        |
| date                      | Datefomat             | Default: 'MBSPLS_DEV_Aug2024_correctionscale_nosignflip_R2022a'                    |
| partition                 | String                | Enter the partition on your server (e.g, jobs-matlab, jobs-cpu-long)                      |
| max_sim_jobs              | Double                | Define how many parallel jobs are created (Default: 10)                   |
| parallel_jobs             | Double                | Define how many jobs run in parallel at the same time (soft threshold) (Default: 25)                   |
| mem_request               | Double                | Memory request for master and slave jobs (in GB; Default: 10)                   |
| matlab_version            | String                | Define MATLAB runtime engine (e.g, R2022a)                   |
| cache_path                | String                | Path for output text files during hyperopt, permutation, bootstrapping => generally same as scratch space                   |
| scratch_space             | String                | % Path for temporary file storage (hyperopt, permutation, bootstrapping) during analysis                   |
| compilation_subpath       | String                | Default: 'for_testing'|

