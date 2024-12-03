(spls_2run)=
# Model Training 

# Software Architecture of the SPLS Toolbox

The SPLS Toolbox is a modular analysis framework implemented in MATLAB and consists of a master module (`dp_spls_standalone`) that oversees the execution of the entire analysis pipeline, and three specialized slave modules dedicated to **hyperparameter optimization**, **bootstrapping**, and **permutation testing**. 

The master module coordinates the workflow by deploying the slave modules as job arrays on a high-performance computing cluster. These job arrays enable parallel processing, significantly reducing the computation time required for large-scale analyses. The modular architecture allows each slave module to handle its specific task independently, while the master module integrates their outputs to generate the final SPLS model. 

All modules have been compiled as standalone MATLAB executables using MATLAB's built-in compiler, ensuring compatibility with high-performance cluster environments managed by Sun Grid Engine (SGE). The deployment process is automated through Bash scripts, which simplify execution and facilitate scalability across different computational infrastructures. This design ensures that the SPLS Toolbox is both efficient and user-friendly, catering to the demands of large datasets and complex machine learning workflows.

---

## Key Modules and Their Functions

| **Module**            | **Explanation**                                                                                                          |
|------------------------|--------------------------------------------------------------------------------------------------------------------------|
| **1. Hyperparameter Optimization** | This module systematically searches in a grid search (`input.density`) for the best hyperparameters (`c_u` and `c_v`) that control the sparsity of the SPLS model. It evaluates a range of hyperparameter combinations to identify those that maximize the correlation between the projections of the two data matrices (e.g., neuroimaging and phenotypic data). By tuning these hyperparameters, the model achieves an optimal balance between interpretability and predictive performance. The process is performed using cross-validation within the inner loop of the SPLS framework (`input.framework`). |
| **2. Bootstrapping**               | The bootstrapping module assesses the stability and reliability of the weight vectors (`u` and `v`) associated with the latent variables (LVs). By generating multiple resampled datasets through sampling with replacement, the module calculates variability in the feature weights, identifying which features consistently contribute to the SPLS model. This helps quantify the robustness of the model and supports interpretation by highlighting key features that are reliably associated across resamples. |
| **3. Permutation Testing**         | This module evaluates the statistical significance of the latent variables identified by SPLS. It creates a large number of randomized datasets by permuting the phenotypic data matrix, effectively destroying the relationships between the two data matrices. The module then trains the SPLS model on these permuted datasets and compares their performance (correlation between projections) to that of the original model. A p-value is calculated to determine the likelihood of observing the original model's performance by chance, providing robust statistical validation

Temporary files and results for each step are stored in `input.scratch_space`. For more information and references, please see [References](references.md).
