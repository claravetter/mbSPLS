%% SCRIPT TO RETRIEVE (MB-)SPLS RESULTS
% 10.09.2024
clear

% ADD PATHS 
addpath(genpath('/volume/projects/CV_gs_PLS/ScrFun/multiblock_spls/'))
addpath(genpath('/opt/NM/NeuroMiner_1.3_Debugging'))
addpath(genpath('/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS'))
% cd /opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS

% DEFINE PATH TO RESULT FILE
filepath = '/volume/projects/CW_Med/Data/Steiner/Analysis/Relevant/CW_mbspls_PRS_BLOOD_PROTEOMIC_SOCIO_5x5_1000perm_100boot_fro_matrixnorm_grid_search_10_10_10_10_densities/CW_mbspls_PRS_BLOOD_PROTEOMIC_SOCIO_5x5_1000perm_100boot_fro_matrixnorm_grid_search_10_10_10_10_densities/final_results/preliminary_result.mat';

% RUN SCRIPT TO RETRIEVE RESULTS & CREATE REPORT
% (A) DISPLAY ALL FEATURES
cw_spls_results(filepath)

% (B) DISPLAY ONLY TOP X FEATURES
maxFeatures = 20; 
% cw_spls_results(filepath, 'maxFeatures', 20, 'report_Flag', false, 'figureFormat', 'eps')
cw_spls_results(filepath, 'maxFeatures', 20, 'report_Flag', false)

