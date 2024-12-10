%% SCRIPT TO RETRIEVE (MB-)SPLS RESULTS
% 10.09.2024
clear

% ADD PATHS 
addpath(genpath('/volume/projects/CV_gs_PLS/ScrFun/multiblock_spls/'))
addpath(genpath('/opt/NM/NeuroMiner_1.3_Debugging'))
addpath(genpath('/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS'))
% cd /opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS

% DEFINE PATH TO RESULT FILE
filepath = '/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS/3_Results/Testing/result.mat';

% RUN SCRIPT TO RETRIEVE RESULTS & CREATE REPORT
% (A) DISPLAY ALL FEATURES
mb_spls_results_main(filepath)

% (B) DISPLAY ONLY TOP X FEATURES
% maxFeatures = 20; 
% cw_spls_results(filepath, 'maxFeatures', 20, 'report_Flag', false, 'figureFormat', 'eps')
mb_spls_results_main(filepath, 'maxFeatures', 20, 'report_Flag', false)

