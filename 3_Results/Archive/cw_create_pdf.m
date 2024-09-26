function [] = cw_create_pdf(filepath)
% TO DO
% Restructure Xs
% Sections for Figures (before/after bootstrapping)
% Check if we need to list more input/setup options
% Integrate it in "spls_results.m"?
% Add Table with main results? 
    % per LV: p value, Matrix norm, explained variance

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscellstr(filepath)
    filepath = char(filepath); 
    data = load(filepath);
elseif ~iscell(filepath) && (ischar(filepath) || istring(filepath))
    data = load(filepath);
end

INPUT = data.input; 
SETUP = data.setup; 
OUTPUT = data.output; 

clear data

import mlreportgen.report.*
import mlreportgen.dom.*

[folderpath, ~, ~] = fileparts(filepath);

% folderpath = '/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS/3_Results';

% CREATE FOLDER FOR REPORT
path2test = '/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS/3_Results/';
Path2Report = fullfile(path2test, 'Reports');

% Path2Report = fullfile(folderpath, 'Reports');
if ~exist(Path2Report)
    mkdir(Path2Report)
end

% Define the path where you want to save the report
outputFileName = 'Report.pdf';

% Combine the path and filename
fullFilePath = fullfile(Path2Report, outputFileName);

% Create a report object with the specified path
rpt = Report(fullFilePath, 'pdf');

% Add a title page
titlepg = TitlePage;
titlepg.Title = 'Analysis Report';
% titlepg.Subtitle = 'Analysis of Experimental Data';
titlepg.Author = '  ';
titlepg.PubDate = date;
% titlepg.Description = 'This report covers the results of the mb-sPLS analysis including data preprocessing, model training, and validation steps.';
titlepg.Image = '/opt/PrecisionCodeRep/SPLS_Toolbox/mbSPLS/3_Results/mbspls_logo_klein.png'; % Optional
add(rpt, titlepg);

% Add a custom description after the title page
% desc = Paragraph('This report covers the results of the mb-sPLS analysis, including data preprocessing, model training, and validation steps.');
% add(rpt, desc);

%% TABLE OF CONTENTS
% Add a table of contents
toc = TableOfContents;
add(rpt, toc);

%% CHAPTER 1
% Create a chapter for input settings
ch1 = Chapter('Title', 'Input');
vars = {'name', 'Xs', 'type_correction', 'covariates', 'covariates_names', ...
    'DiagNames', 'framework', 'outer_folds', 'inner_folds', ...
    'permutation_testing', 'bootstrap_testing',...
    'optimization_strategy', 'density', 'correlation_method', 'mult_test', 'statistical_testing'};

cw_addFieldsToReport(ch1, INPUT, 'Input Parameters', vars); clear vars

% add(ch1, 'List of input settings and data:');
% % Add list or table of input settings
% inputDataText = 'Your input data and settings list...';
% para = Paragraph(inputDataText);
% add(ch1, para);

% Add the chapter to the report
add(rpt, ch1);

%% CHAPTER 2
ch2 = Chapter('Title', 'Setup');
% add(ch1, 'List of setup settings:');
vars = {'date', 'analysis_folder', 'data_folder', 'standalone_version', ...
    'mbspls_standalone_path', 'matlab_version'};
cw_addFieldsToReport(ch2, SETUP, 'Setup Parameters', vars);
add(rpt, ch2);

%% Chapter 3
ch3 = Chapter('Title', 'Results');

T = table([], [], [], [], 'VariableNames', {'LV', 'P value', 'Frobenius Norm', 'R2'});

for lv_idx = 1:height(OUTPUT.final_parameters)
    T.LV(lv_idx) = lv_idx;
    T.("P value")(lv_idx) = OUTPUT.final_parameters{lv_idx, matches(OUTPUT.parameters_names, 'p')};
    T.("Frobenius Norm")(lv_idx) = OUTPUT.final_parameters{lv_idx, matches(OUTPUT.parameters_names, 'RHO')};
    T.R2(lv_idx) = 1;
end

cw_create_table_for_pdf(ch3, T)
add(rpt, ch3)

%% CHAPTER 3
% Create a chapter for images and outputs
ch4 = Chapter('Title', 'Figures');

plotType = {'Barplots', 'Heatmaps'};
for p = 1:numel(plotType)
    path2figures = fullfile(folderpath, 'Figures', plotType{p});
    if exist(path2figures)
        % Get the contents of the folder
        folderContents = dir(path2figures);
        for i = 1:length(folderContents)
            if contains(folderContents(i).name, 'LV') && ~folderContents(i).isdir
                source = fullfile(path2figures, folderContents(i).name);
                imageObj = mlreportgen.dom.Image(source);
                imageObj.Style = {ScaleToFit};
                add(ch4, imageObj)
            end
        end
    end
    clear path2figures
end

add(rpt, ch4);

% Close and view the report
close(rpt);
rptview(rpt);