(mbspls_2run)=
# Model Training

The function `<placeholder>`creates a slurm script, which submits the `datafile.mat` that was created in the [Data Input](mbspls_1setup.md) step to the mb-SPLS toolbox, with the following structure:

```bash
#!/bin/sh 
#SBATCH --error=PathToErrorFile-%j.err # (e.g., /path/to/your/project/output-%j.err)
#SBATCH --output=PathToOutputFile-%j.log # (e.g., /path/to/your/project/output-%j.log)
#SBATCH --partition=PartitionName # (e.g., jobs-cpu-long)
#SBATCH --account=AccountName # (e.g., core-psy)
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --job-name JobName # (e.g., mbspls_main)
#SBATCH --mem=MemoryAmount # (e.g., 10GB)

$PMODE
export MCR_CACHE_ROOT=PathToCache # (e.g., /path/to/cache)
export LD_LIBRARY_PATH=PathToMatlabRuntime # (e.g., /path/to/matlab/runtime/glnxa64:/path/to/matlab/bin/glnxa64:/path/to/matlab/sys/os/glnxa64)
cd PathToWorkingDirectory # (e.g., /data/core-psy-archive/projects/CW_NfL/Analysis/PRS_auto_BLOOD_PROTEOMIC_SOCIO/02-Dec-2024)

/Path/To/Toolbox/ # (e.g., /data/core-psy-archive/projects/CV_mbspls/mbspls/MBSPLS_DEV_Oct2024_R2023b/for_testing/MBSPLS_DEV_Oct2024_R2023b) 
/Path/To/Datafile # (e.g., /data/core-psy-archive/projects/CW_NfL/Data/PRS_auto_BLOOD_PROTEOMIC_SOCIO/02-Dec-2024/02-Dec-2024_CW_mbspls_PRS_auto_BLOOD_PROTEOMIC_SOCIO_5x5_1000perm_100boot_Benjamini_Hochberg_fro_matrixnorm_grid_search_20_20_20_20_datafile.mat)
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
