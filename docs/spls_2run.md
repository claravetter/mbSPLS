(spls_2run)=
# Model Training 

The function `<placeholder>`creates a slurm script, which submits the `datafile.mat` that was created in the [Data Input](spls_1setup.md) step to the SPLS toolbox, with the following structure:

```bash
#!/bin/sh 
#SBATCH --error=PathToErrorFile-%j.err # (e.g., /path/to/your/project/output-%j.err)
#SBATCH --output=PathToOutputFile-%j.log # (e.g., /path/to/your/project/output-%j.log)
#SBATCH --partition=PartitionName # (e.g., jobs-cpu-long)
#SBATCH --account=AccountName # (e.g., core-psy)
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --job-name JobName # (e.g., spls_main)
#SBATCH --mem=MemoryAmount # (e.g., 10GB)
$PMODE
export MCR_CACHE_ROOT=PathToCache # (e.g., /data/core-psy-archive/projects/CW_NfL/Cache )
export LD_LIBRARY_PATH=PathToMatlabRuntime # (e.g., /path/to/matlab/runtime/glnxa64:/path/to/matlab/bin/glnxa64:/path/to/matlab/sys/os/glnxa64)
cd PathToWorkingDirectory # (e.g., /data/core-psy-archive/projects/CW_NfL/Analysis/PRS_auto_BLOOD_PROTEOMIC_SOCIO/02-Dec-2024)

/Path/To/Toolbox # (e.g., /data/core-psy-pronia/opt/SPLS_Toolbox_Dev_2023_CORE/dp_spls_standalone/for_testing/dp_spls_standalone) 
/Path/To/Datafile.mat # (e.g., /data/core-psy-archive/projects/CW_NfL/Data/PRS_auto_BLOOD_PROTEOMIC_SOCIO/02-Dec-2024/02-Dec-2024_CW_spls_PRS_auto_BLOOD_PROTEOMIC_SOCIO_5x5_1000perm_100boot_Benjamini_Hochberg_density20_datafile.mat)
```

| **Input**                       | **Description**                                                                                                   |
|----------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `PathToErrorFile-%j.err`         | Specifies the file where errors from the job will be logged. `%j` is replaced by the job ID during execution.            |
| `PathToOutputFile-%j.log`        | Specifies the file where standard output from the job will be logged. `%j` is replaced by the job ID during execution.   |
| `PartitionName`                  | Specifies the partition (queue) where the job will run (e.g., `jobs-cpu-long`).                                          |
| `AccountName`                    | Specifies the account to charge for the job (e.g., `core-psy`).                                                          |
| `JobName`                        | Sets a name for the job (e.g., `mbspls_main`), helpful for tracking jobs in the SLURM queue.                             |
| `MemoryAmount`                   | Specifies the memory allocation for the job (e.g., `10GB`).                                                              |
| `PathToCache`                    | Sets the directory for MATLAB's MCR (MATLAB Compiler Runtime) temporary files (e.g., `/path/to/cache`).                  |
| `PathToMatlabRuntime`            | Configures the paths to MATLAB runtime libraries needed to execute the compiled MATLAB application. |
| `PathToProjectFolder`            | Changes the directory to your project folder where the script will be executed (e.g., `/path/to/project/folder`).   |
| `PathToToolbox`                  | Specifies the path to the compiled mbSPLS toolbox.                         |
| `PathToDatafile`                 | Specifies the full path to the input data file (e.g., `/path/to/datafile.mat`).            |

---

The SPLS Toolbox is a modular analysis framework implemented in MATLAB and consists of a master module (`dp_spls_standalone`) that oversees the execution of the entire analysis pipeline, and three specialized slave modules dedicated to **hyperparameter optimization**, **bootstrapping**, and **permutation testing**. 

The master module coordinates the workflow by deploying the slave modules as job arrays on a high-performance computing cluster. These job arrays enable parallel processing, significantly reducing the computation time required for large-scale analyses. The modular architecture allows each slave module to handle its specific task independently, while the master module integrates their outputs to generate the final SPLS model. 

All modules have been compiled as standalone MATLAB executables using MATLAB's built-in compiler, ensuring compatibility with high-performance cluster environments managed by Sun Grid Engine (SGE). The deployment process is automated through Bash scripts, which simplify execution and facilitate scalability across different computational infrastructures. This design ensures that the SPLS Toolbox is both efficient and user-friendly, catering to the demands of large datasets and complex machine learning workflows.

---

| **Module**            | **Explanation**                                                                                                          |
|------------------------|--------------------------------------------------------------------------------------------------------------------------|
| **1. Hyperparameter Optimization** | This module systematically searches in a grid search (`input.density`) for the best hyperparameters  that control the sparsity of the SPLS model. It evaluates a range of hyperparameter combinations to identify those that maximize the correlation between the projections of the data matrices (e.g., neuroimaging, phenotypic data). By tuning these hyperparameters, the model achieves an optimal balance between interpretability and predictive performance. The process is performed using cross-validation within the inner loop of the SPLS framework (defined by `input.framework`). |
| **2. Bootstrapping**               | The bootstrapping module assesses the stability and reliability of the weight vectors associated with the latent variables (LVs). By generating multiple resampled datasets through sampling with replacement, the module calculates variability in the feature weights, identifying which features consistently contribute to the SPLS model. This helps quantify the robustness of the model and supports interpretation by highlighting key features that are reliably associated across resamples. |
| **3. Permutation Testing**         | This module evaluates the statistical significance of the latent variables identified by the algorithm. It creates a large number of randomized datasets by permuting one data matrix, effectively destroying the relationships between the data matrices. The module then trains the SPLS model on these permuted datasets and compares their performance (correlation between projections) to that of the original model. A p-value is calculated to determine the likelihood of observing the original model's performance by chance, providing robust statistical validation

Temporary files and results for each step are stored in `input.scratch_space`. For more information and references, please see [References](references.md).
