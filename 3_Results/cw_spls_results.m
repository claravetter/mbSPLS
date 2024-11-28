function cw_spls_results(filepath, varargin)
% TO DO
% Figures: Number of Matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser;

addRequired(p, 'filepath', @ischar)
addParameter(p, 'maxFeatures', [], @isnumeric);
addParameter(p, 'report_flag', true, @islogical);
% addParameter(p, 'figureFormat', 'png', @ischar);

parse(p, filepath, varargin{:});
maxFeatures = p.Results.maxFeatures;
report_flag = p.Results.report_flag;
% figureFormat = p.Results.figureFormat; 

% LOAD FILEPATH
if iscellstr(filepath)
    filepath = char(filepath);
    data = load(filepath);
elseif ~iscell(filepath) && (ischar(filepath) || istring(filepath))
    data = load(filepath);
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

% CREATE FOLDER FOR REPORT
% path2test = '/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS/3_Results/';
% Path2Report = fullfile(path2test, 'Reports');

Path2Report = fullfile(folderpath, 'Reports');
if ~exist(Path2Report)
    mkdir(Path2Report)
end

% CHECK WHETHER NUMBER OF TOP FEATURES FOR FIGURES WAS DEFINED (BARPLOT)
% if isempty(varargin)
%     maxFeatures = [];
% else
%     maxFeatures = varargin{1};
% end

%% BEFORE BOOTSTRAPPING
% CORRECTION
switch data.input.type_correction
    case {'correct', 'corrected'}
        correct_log = true;
    case {'uncorrected','uncorrect'}
        correct_log = false;
end

% LOOP THROUGH MATRICES
for matrix_idx = 1:numel(data.input.Xs)
    % CREATE EMPTY TABLE
    T = table();
    % LOOP THROUGH LATENT VARIABLES
    for lv_idx = 1:height(data.output.final_parameters)
        % SAVE FEATURE NAMES IN TABLE
        T.VariableName = data.input.Xs_feature_names{1, matrix_idx}.';
        T.(['LV', num2str(lv_idx)]) = data.output.final_parameters{lv_idx, 3}{1, matrix_idx};
    end

    % SAVE TABLE AS EXCEL FILE (SHEET)
    writetable(T, fullfile(Path2Tables, 'LV_results.xlsx'), 'Sheet', data.input.Xs_names{matrix_idx})
    clear T
end
clear matrix_idx lv_idx


if report_flag
    import mlreportgen.report.*
    import mlreportgen.dom.*

    % [folderpath, ~, ~] = fileparts(filepath);

    % folderpath = '/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS/3_Results';

    % Define the path where you want to save the report
    outputFileName = [date, '_Report.pdf'];

    % Combine the path and filename
    fullFilePath = fullfile(Path2Report, outputFileName);

    % // REPORT
    rpt = Report(fullFilePath, 'pdf');

    % // REPORT: TITLE PAGE
    titlepg = TitlePage;
    titlepg.Title = 'REPORT';
    % titlepg.Subtitle = 'Analysis of Experimental Data';
    titlepg.Author = '  ';
    titlepg.PubDate = '   ';
    titlepg.Image = '/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS/3_Results/mbspls_logo_klein.png'; % Optional
    add(rpt, titlepg);
    desc = Paragraph(['ANALYSIS:', newline, data.input.name]);
    desc.Style = {HAlign('center')};
    add(rpt, desc);
    for i = 1:12
        add(rpt, Paragraph(' '));
    end

    desc = Paragraph('© 2024 Section for Precision Psychiatry. All rights reserved.');
    desc.Style = {HAlign('center')};
    add(rpt, desc);

    % // REPORT: TABLE OF CONTENTS
    toc = TableOfContents;
    add(rpt, toc);

    % // REPORT: CHAPTER 1 (SETUP)
    ch1 = Chapter('Title', 'Setup');
    vars = {'date', 'analysis_folder', 'data_folder', 'standalone_version', ...
        'mbspls_standalone_path', 'matlab_version'};
    cw_addFieldsToReport(ch1, data.setup, 'Settings', vars);
    add(rpt, ch1);

    % // REPORT: CHAPTER 1 (INPUT)
    % Input Data
    ch2 = Chapter('Title', 'Input');
    vars = {'Xs', 'covariates'};
    cw_addFieldsToReport(ch2, data.input, 'Input Data', vars); clear vars
    add(ch2, Paragraph(' '))

    % Machine Learning Framework
    vars = {'framework', 'outer_folds', 'inner_folds', ...
        'permutation_testing', 'bootstrap_testing',...
        'optimization_strategy', 'density', 'correlation_method', ...
        'mult_test', 'statistical_testing'};

    cw_addFieldsToReport(ch2, data.input, 'Machine Learning Framework', vars); clear vars
    add(rpt, ch2);

    % // REPORT: CHAPTER 3 (RESULTS)
    ch3 = Chapter('Title', 'Results');
    add(ch3, Paragraph(' '))

    T = table([], [], [], [], 'VariableNames', {'LV', 'P value', 'Frobenius Norm', 'R2'});

    for lv_idx = 1:height(data.output.final_parameters)
        T.LV(lv_idx) = lv_idx;
        T.("P value")(lv_idx) = data.output.final_parameters{lv_idx, matches(data.output.parameters_names, 'p')};
        T.("Frobenius Norm")(lv_idx) = data.output.final_parameters{lv_idx, matches(data.output.parameters_names, 'RHO')};
        T.R2(lv_idx) = 1;
    end

    cw_create_table_for_pdf(ch3, T)
    add(rpt, ch3)
end

% LATENT SCORES
[LS] = cv_cw_spls_get_latent_scores(data.input, data.output, correct_log, [], Path2Tables);
% [AUTOMATICALLY SAVES TABLE]

% FIGURES: HEATMAP [LATENT SCORES]
cw_spls_results_figures(LS, [], 'heatmap', Path2Figures)
clear LS

% FIGURES: BARPLOTS [LATENT VARIABLES]
cw_spls_results_figures(data, [], 'barplot', Path2Figures, maxFeatures)
clear input output setup clear data

%% WITH BOOTSTRAPPING
boot_options = {'BS', 'CI'};
for ii=1:numel(boot_options)
    % GET RESULTS AFTER BOOTSTRAPPING
    % [boot_results_file, input, output] = cv_cw_mbspls_bootstrap_pruning(filepath, boot_options{ii});
    [BS_input, BS_output] = cv_cw_mbspls_bootstrap_pruning(filepath, boot_options{ii});

    % LOOP THROUGH MATRICES
    for matrix_idx = 1:numel(BS_input.Xs)
        % CREATE EMPTY TABLE
        T = table();
        % LOOP THROUGH LATENT VARIABLES
        for lv_idx = 1:height(BS_output.final_parameters)
            T.VariableName = BS_input.Xs_feature_names{1, matrix_idx}.';
            T.(['LV', num2str(lv_idx)]) = BS_output.final_parameters{lv_idx, matches(BS_output.parameters_names, 'weights')}{1, matrix_idx};
        end

        % SAVE AS EXCEL FILE
        writetable(T, fullfile(Path2Tables, ['LV_results_', boot_options{ii}, '.xlsx']),  'Sheet', BS_input.Xs_names{matrix_idx})
        clear T
    end

    % LATENT SCORES
    [LS] = cv_cw_spls_get_latent_scores(BS_input, BS_output, correct_log, boot_options{ii}, Path2Tables);
    % [LS] = cv_cw_spls_get_latent_scores(boot_results_file, correct_log, boot_options{ii});

    % FIGURES: HEATMAP [LATENT SCORES]
    cw_spls_results_figures(LS, boot_options{ii}, 'heatmap', Path2Figures)

    % FIGURES: BARPLOTS [LATENT VARIABLES]
    BS_data.input = BS_input; BS_data.output = BS_output;
    cw_spls_results_figures(BS_data, boot_options{ii}, 'barplot', Path2Figures, maxFeatures)
    clear boot_results_file LS BS_input BS_output BS_data
end

% // REPORT: CHAPTER 4 (FIGURES)
ch4 = Chapter('Title', 'Figures');
add(ch4, Paragraph(' '))
para = Paragraph('Before Boostrapping');
para.Style = {Bold(true)};
add(ch4, para);
plotType = {'Barplots', 'Heatmaps'};

% > BEFORE BOOTSTRAPPING
for p = 1:numel(plotType)
    path2figures = fullfile(folderpath, 'Figures', plotType{p});
    if exist(path2figures)
        % Get the contents of the folder
        folderContents = dir(path2figures);
        for i = 1:length(folderContents)
            if ~isempty(maxFeatures)
                if (strcmp(plotType{p}, 'Barplots') && contains(folderContents(i).name, 'LV') && ~contains(folderContents(i).name, {'BS', 'CI'}) && contains(folderContents(i).name, 'top')) || ...
                        (strcmp(plotType{p}, 'Heatmaps') && contains(folderContents(i).name, 'LV') && ~contains(folderContents(i).name, {'BS', 'CI'}))
                    source = fullfile(path2figures, folderContents(i).name);
                    imageObj = mlreportgen.dom.Image(source);
                    imageObj.Style = {ScaleToFit};
                    add(ch4, imageObj)
                end
            else
                if contains(folderContents(i).name, 'LV') && ~contains(folderContents(i).name, {'BS', 'CI'})
                    source = fullfile(path2figures, folderContents(i).name);
                    imageObj = mlreportgen.dom.Image(source);
                    imageObj.Style = {ScaleToFit};
                    add(ch4, imageObj)
                end
            end
        end
    end
    clear path2figures
end

add(ch4, Paragraph(' '))
para = Paragraph('After Boostrapping (CI)');
para.Style = {Bold(true), PageBreakBefore(true)};
add(ch4, para);

% AFTER BOOTSTRAPPING (CI)
for p = 1:numel(plotType)
    path2figures = fullfile(folderpath, 'Figures', plotType{p});
    if exist(path2figures)
        % Get the contents of the folder
        folderContents = dir(path2figures);
        for i = 1:length(folderContents)
            if ~isempty(maxFeatures)
                if (strcmp(plotType{p}, 'Barplots') && contains(folderContents(i).name, 'LV') && contains(folderContents(i).name, 'CI') && contains(folderContents(i).name, 'top')) || ...
                        (strcmp(plotType{p}, 'Heatmaps') && contains(folderContents(i).name, 'LV') && contains(folderContents(i).name, 'CI'))
                    source = fullfile(path2figures, folderContents(i).name);
                    imageObj = mlreportgen.dom.Image(source);
                    imageObj.Style = {ScaleToFit};
                    add(ch4, imageObj)
                end
            else
                if contains(folderContents(i).name, 'LV') && contains(folderContents(i).name, 'CI')
                    source = fullfile(path2figures, folderContents(i).name);
                    imageObj = mlreportgen.dom.Image(source);
                    imageObj.Style = {ScaleToFit};
                    add(ch4, imageObj)
                end
            end
        end
    end
    clear path2figures
end

add(ch4, Paragraph(' '))
para = Paragraph('After Boostrapping (BS)');
para.Style = {Bold(true), PageBreakBefore(true)};
add(ch4, para);

% AFTER BOOTSTRAPPING (BS)
for p = 1:numel(plotType)
    path2figures = fullfile(folderpath, 'Figures', plotType{p});
    if exist(path2figures)
        % Get the contents of the folder
        folderContents = dir(path2figures);
        for i = 1:length(folderContents)
            if ~isempty(maxFeatures)
                if (strcmp(plotType{p}, 'Barplots') && contains(folderContents(i).name, 'LV') && contains(folderContents(i).name, 'BS') && contains(folderContents(i).name, 'top')) || ...
                        (strcmp(plotType{p}, 'Heatmaps') && contains(folderContents(i).name, 'LV') && contains(folderContents(i).name, 'BS'))
                    source = fullfile(path2figures, folderContents(i).name);
                    imageObj = mlreportgen.dom.Image(source);
                    imageObj.Style = {ScaleToFit};
                    add(ch4, imageObj)
                end
            else
                if contains(folderContents(i).name, 'LV') && contains(folderContents(i).name, 'BS')
                    source = fullfile(path2figures, folderContents(i).name);
                    imageObj = mlreportgen.dom.Image(source);
                    imageObj.Style = {ScaleToFit};
                    add(ch4, imageObj)
                end
            end
        end
    end
    clear path2figures
end

if report_flag
    add(rpt, ch4);


    % FINISH UP REPORT
    close(rpt);
    rptview(rpt);
end