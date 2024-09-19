function cw_spls_results(filepath, varargin)
% TO DO
% Figures: Number of Matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LOAD FILEPATH
if iscellstr(filepath)
    filepath = char(filepath); 
    load(filepath)
elseif ~iscell(filepath) && (ischar(filepath) || istring(filepath))
    load(filepath)
end

% RETRIEVE PATH TO ANALYSIS FOLDER
[folderpath, ~, ~] = fileparts(filepath);

% CREATE FOLDER FOR TABLES [IN ANALYSIS FOLDER]
Path2Tables = fullfile(folderpath, 'Tables');
if ~exist(Path2Tables)
    mkdir(Path2Tables)
end

% CREATE FOLDER FOR FIGURES [IN ANALYSIS FOLDER]
Path2Figures = fullfile(folderpath, 'Figures');
if ~exist(Path2Figures)
    mkdir(Path2Figures)
end

% CHECK WHETHER NUMBER OF TOP FEATURES FOR FIGURES WAS DEFINED (BARPLOT)
if isempty(varargin)
    maxFeatures = []; 
else 
    maxFeatures = varargin{1}; 
end 

%% BEFORE BOOTSTRAPPING
% CORRECTION
switch input.type_correction
    case 'corrected'
        correct_log = true;
    case 'correct'
        correct_log = true;
    case 'uncorrected' 
        correct_log = false;
    case 'uncorrect' 
        correct_log = false;    
end

% LOOP THROUGH MATRICES
for matrix_idx = 1:numel(input.Xs)
    % CREATE EMPTY TABLE
    T = table();
    % LOOP THROUGH LATENT VARIABLES
    for lv_idx = 1:height(output.final_parameters)
        % SAVE FEATURE NAMES IN TABLE
        T.VariableName = input.Xs_feature_names{1, matrix_idx}.';
        T.(['LV', num2str(lv_idx)]) = output.final_parameters{lv_idx, 3}{1, matrix_idx};
    end

    % SAVE TABLE AS EXCEL FILE (SHEET)
    writetable(T, fullfile(Path2Tables, 'LV_results.xlsx'), 'Sheet', input.Xs_names{matrix_idx})
    clear T 
end
clear matrix_idx lv_idx

% LATENT SCORES
[LS] = cv_cw_spls_get_latent_scores(input, output, correct_log, [], Path2Tables);
% [AUTOMATICALLY SAVES TABLE]

% FIGURES: HEATMAP [LATENT SCORES]
cw_spls_results_figures(LS, [], 'heatmap', Path2Figures)
clear LS

% FIGURES: BARPLOTS [LATENT VARIABLES]
data.input = input; data.output = output; 
cw_spls_results_figures(data, [], 'barplot', Path2Figures, maxFeatures)
clear input output setup clear data

%% WITH BOOTSTRAPPING
boot_options = {'CI', 'BS'};
for ii=1:numel(boot_options)
    % GET RESULTS AFTER BOOTSTRAPPING
    % [boot_results_file, input, output] = cv_cw_mbspls_bootstrap_pruning(filepath, boot_options{ii});
    [input, output] = cv_cw_mbspls_bootstrap_pruning(filepath, boot_options{ii});

    % LOOP THROUGH MATRICES
    for matrix_idx = 1:numel(input.Xs)
        % CREATE EMPTY TABLE
        T = table();
        % LOOP THROUGH LATENT VARIABLES
        for lv_idx = 1:height(output.final_parameters)
            T.VariableName = input.Xs_feature_names{1, matrix_idx}.';
            T.(['LV', num2str(lv_idx)]) = output.final_parameters{lv_idx, matches(output.parameters_names, 'weights')}{1, matrix_idx};
        end

        % SAVE AS EXCEL FILE
        writetable(T, fullfile(Path2Tables, ['LV_results_', boot_options{ii}, '.xlsx']),  'Sheet', input.Xs_names{matrix_idx})
        clear T
    end

    % LATENT SCORES
    [LS] = cv_cw_spls_get_latent_scores(input, output, correct_log, boot_options{ii}, Path2Tables);
    % [LS] = cv_cw_spls_get_latent_scores(boot_results_file, correct_log, boot_options{ii});

    % FIGURES: HEATMAP [LATENT SCORES]
    cw_spls_results_figures(LS, boot_options{ii}, 'heatmap', Path2Figures)

    % FIGURES: BARPLOTS [LATENT VARIABLES]
    data.input = input; data.output = output;
    cw_spls_results_figures(data, boot_options{ii}, 'barplot', Path2Figures, maxFeatures)
    clear boot_results_file LS input output data
end
