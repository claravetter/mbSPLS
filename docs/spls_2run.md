(spls_2run)=
# Model Training 

ADAPT (took it from ChatGPT) 

During model training, a **main job** coordinates multiple **slave jobs**. These slave jobs are dedicated to specific tasks: **hyperparameter optimization**, **permutation testing**, and **bootstrapping**.  

---

## 1. Hyperparameter Optimization

Hyperparameter optimization is a cornerstone of the sPLS workflow, balancing the sparsity of the model with predictive accuracy. This task is handled as a **slave job** that incorporates a flexible cross-validation framework defined in `input.framework`. While nested cross-validation is an option, users can also specify alternative frameworks, such as Leave-Some-Out Cross-Validation (LSOCV) or other custom schemes.

In this step, the data is split according to the specified cross-validation framework. For each split, the model is trained on a subset of the data, and its performance is evaluated on the hold-out set. The sparsity of the model is tuned using a grid search, guided by the `input.density` parameter. This parameter defines the number of grid points (on a scale from 0 to 100) that are tested during the optimization process, allowing users to control the granularity of the search. Higher values of `input.density` result in finer-grained searches, exploring a larger number of potential sparsity configurations.

Each hyperparameter configuration is evaluated using performance metrics such as mean squared error or the correlation between predicted and true responses. The configuration that performs best across all cross-validation folds is selected as the optimal setup. 

---

## 2. Permutation Testing

Permutation testing, managed by a dedicated **slave job**, evaluates the statistical significance of the sPLS model's performance. This process ensures that the observed relationships between predictors and the response are not artifacts of random chance. 

The response variable is permuted multiple times, breaking any true associations in the data. For each permutation, the model is retrained using the same cross-validation framework and hyperparameters as the original model. The performance metrics obtained from these permuted datasets form a null distribution, representing the expected performance under random conditions.

The actual model's performance is compared against this null distribution to calculate a p-value, indicating the likelihood of achieving the observed performance by chance. In the sparse context of sPLS, this step is essential to validate that the sparsity-inducing penalties are not overfitting to noise or spurious correlations. 

---

## 3. Bootstrapping

Bootstrapping, handled by another **slave job**, provides an assessment of the stability and reliability of the sPLS model. This step evaluates the variability in variable selection, sparse loadings, and model predictions across different resampled datasets.

Bootstrap samples are created by sampling the original data with replacement, and the sPLS model is retrained on each sample. This process allows for the estimation of confidence intervals for performance metrics and model parameters. Additionally, bootstrapping is particularly useful in sPLS for assessing the consistency of selected variables across resampled datasets. Variables that are consistently selected across bootstrap iterations are more likely to represent meaningful features of the data.

---

Temporary files and results for each step are stored in `input.scratch_space`. For more information and references, please see [References](references.md).
