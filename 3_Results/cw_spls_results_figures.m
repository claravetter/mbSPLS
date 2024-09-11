function cw_spls_results_figures(data, mode, type, path, maxFeatures)

switch type
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LV FIGURES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'barplot'
        path = fullfile(path, 'Barplots');
        if ~exist(path)
            mkdir(path)
        end 
        % Loop through LVs
        input = data.input; 
        output = data.output; 
        clear data
        for lv_idx = 1:height(output.final_parameters)

            % Determine the number of subplots based on the available data
            num_subplots = min(numel(input.Xs), 4); % Ensure you have at least 2 and at most 4 subplots

            % Create a new figure for combining the subplots
            combined_fig = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);

            % Set subplot layout to be a 2x2 grid
            subplot_rows = 2;
            subplot_cols = 2;

            for subplot_idx = 1:num_subplots
                % Extract feature names and weights for the current subplot
                feature_names = input.Xs_feature_names{1, subplot_idx}.';
                feature_weights = output.final_parameters{lv_idx, 3}{1, subplot_idx};
                feature_names = strrep(feature_names, '_', ' ');

                % Filter out the features with weight equal to 0
                nonzero_indices = feature_weights ~= 0;
                filtered_feature_names = feature_names(nonzero_indices);
                filtered_feature_weights = feature_weights(nonzero_indices);

                % Sort the features by weight
                [sorted_weights, sort_idx] = sort(filtered_feature_weights, 'descend');
                sorted_feature_names = filtered_feature_names(sort_idx);

                absWeights = abs(sorted_weights);
                % Sort the absolute values in descending order and get the indices
                [~, sortedIndices] = sort(absWeights, 'descend');

                if ~isempty(maxFeatures)
                    % Extract the top X indices
                    if maxFeatures > numel(absWeights)
                        topXIndices = sortedIndices(1:numel(absWeights));
                    else
                        topXIndices = sortedIndices(1:maxFeatures);
                    end

                    sorted_weights = sorted_weights(topXIndices);
                    sorted_feature_names = sorted_feature_names(topXIndices);
                else
                    sorted_weights = sorted_weights(sortedIndices);
                    sorted_feature_names = sorted_feature_names(sortedIndices);
                end

                % Determine the number of features after filtering
                num_filtered_features = numel(sorted_feature_names);

                % Define Colors
                % A. Positive
                positive_colors = [...
                    92/255, 107/255, 192/255;
                    67/255, 160/255, 71/255;
                    0.98, 0.52, 0.02;
                    0.87, 0.49, 0.49];

                % Negative
                negative_colors = [...
                    140/255, 158/255, 255/255;
                    129/255, 199/255, 132/255;
                    1, 0.75, 0.49;
                    0.89, 0.56, 0.56];

                % Create colormap for positively and negatively weighted features
                positive_color = positive_colors(subplot_idx, :);  % Base color for positive features
                negative_color = negative_colors(subplot_idx, :);  % Darker shade for negative features

                % Create the subplot for the current horizontal bar plot
                subplot_handle = subplot(subplot_rows, subplot_cols, subplot_idx); % Create a subplot
                y_positions = 1:length(sorted_weights);

                % Positive weights
                pos_idx = sorted_weights > 0;
                positive_weights = sorted_weights;
                positive_weights(~pos_idx) = NaN;
                barh(y_positions, positive_weights, 'FaceColor', positive_color, 'EdgeColor', 'none');

                hold on

                % Negative Weights
                neg_idx = sorted_weights < 0;
                negative_weights = sorted_weights;
                negative_weights(~neg_idx) = NaN;
                barh(y_positions, negative_weights, 'FaceColor', negative_color, 'EdgeColor', 'none');

                % barh(find(pos_idx), sorted_weights(pos_idx), 'FaceColor', positive_color, 'EdgeColor', 'none');

                % Customize the axes
                ax = gca;
                ax.YTick = 1:num_filtered_features; % Set y-ticks
                ax.YTickLabel = sorted_feature_names; % Set y-tick labels to sorted feature names

                % end
                ax.FontSize = 10; % Set smaller font size for axis labels and ticks
                ax.FontName = 'Arial'; % Set font name for a professional look
                ax.Box = 'off'; % Turn off the box around the plot

                % Ensure feature names are displayed correctly without interpreting underscores
                ax.TickLabelInterpreter = 'none';

                % Label the x-axis with non-bold font
                xlabel('Feature Weights', 'FontSize', 12, 'FontName', 'Arial', 'Interpreter', 'none');

                % Add title with non-bold font
                if contains(input.Xs_names{subplot_idx}, 'X_')
                    header = strrep(input.Xs_names{subplot_idx}, 'X_', '');
                else
                    header = input.Xs_names{subplot_idx};
                end
                title(['Matrix ', num2str(subplot_idx),': ' header], 'FontSize', 13, 'FontName', 'Arial', 'FontWeight', 'normal');

                % Adjust the position to ensure visibility of all elements
                pos = get(subplot_handle, 'Position');

                % if contains(orientation, 'h')
                % Increase space between columns
                if mod(subplot_idx, 2) == 0  % Adjust the second column
                    pos(1) = pos(1) + 0.05; % Shift the second column to the right for more space
                end
                % end

                % The Position property is a four-element vector: [left, bottom, width, height]
                if subplot_idx <= 2  % Adjust the first row
                    pos(2) = pos(2) - 0.04; % Slightly move up the first row
                    pos(4) = pos(4) - 0.02; % Reduce the height slightly
                else  % Adjust the second row
                    pos(2) = pos(2) - 0.02; % Slightly move up the second row to minimize space between rows
                    pos(4) = pos(4) - 0.02; % Reduce the height slightly
                end

                set(subplot_handle, 'Position', pos);
                hold off

            end

            % P VALUE
            if round(output.final_parameters{lv_idx, matches(output.parameters_names, 'p')}, 3) == 0
                pvalue = 'P < .001';
            else
                pvalue = ['P = ', num2str(round(output.final_parameters{lv_idx, matches(output.parameters_names, 'p')}, 3))];
            end

            % RHO
            RHO = num2str(output.final_parameters{lv_idx, matches(output.parameters_names, 'RHO')});

            if isempty(mode)
                mode4title = '';
                suffix4saving = '_barplot_h.png';
            else
                mode4title = [' (', mode, ')'];
                suffix4saving = ['_' mode, '_barplot_h.png'];
            end

            if isempty(maxFeatures)
                topf4title = '* All features are displayed.';
            else
                topf4title = ['* Only Top ', num2str(maxFeatures), ' features are displayed.'];
            end

            % TITLE
            sgtitle(['// LV', num2str(lv_idx), mode4title, ' //', newline, ...
                pvalue, ' | Frobenius Norm = ', RHO, ...
                ' | CV: ', num2str(input.outer_folds), 'x', num2str(input.inner_folds), ...
                ' | Perm: ', num2str(input.permutation_testing), ...
                ' | Boot: ', num2str(input.bootstrap_testing), newline, topf4title], ...
                'FontSize', 16, 'FontName', 'Arial', 'FontWeight', 'normal')

            if ~isempty(maxFeatures)
                figure_name = fullfile(path, ['LV', num2str(lv_idx), '_top', num2str(maxFeatures), 'Feat', suffix4saving])       ;
            else
                figure_name = fullfile(path, ['LV', num2str(lv_idx), suffix4saving]);
            end

            saveas(combined_fig, figure_name);

            close all
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HEATMAP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'heatmap'
        path = fullfile(path, 'Heatmaps');
        if ~exist(path)
            mkdir(path)
        end 

        fields = fieldnames(data);
        for lv_idx = 1:numel(fields)
            X = data.(fields{lv_idx});
            % Calculate the correlation matrix
            DisplayLabels = X.Properties.VariableNames;
            DisplayLabels = strrep(DisplayLabels, '_', ' ');

            X = table2array(X);
            corrMatrix = corr(X);

            % Create a heatmap from the correlation matrix
            % Set the upper triangular part and the diagonal to NaN
            corrMatrix(triu(true(size(corrMatrix)), 0)) = NaN;

            % Create a heatmap from the correlation matrix
            figure;
            h = heatmap(corrMatrix, 'MissingDataLabel', 'NaN');

            % Create a custom blue-to-red colormap
            n = 256; % Number of colors in the colormap
            % Create two halves of the colormap
            % Define the blue to white portion for negative correlations
            blue_to_white = [linspace(0, 1, n/2)', linspace(0, 1, n/2)', ones(n/2, 1)];  % Blue (negative) to white (neutral)

            % Define the white to red portion for positive correlations
            white_to_red = [ones(n/2, 1), linspace(1, 0, n/2)', linspace(1, 0, n/2)'];   % White (neutral) to red (positive)

            % Combine the two halves into a single colormap
            customColormap = [blue_to_white; white_to_red];
            % Combine the two halves to form the full colormap
            % customColormap = [blue_half; flipud(red_half)];
            h.Colormap = customColormap;
            % h.Colormap = redbluecmap; % You can use other colormaps like 'parula', 'hot', etc.
            h.ColorLimits = [-1 1]; % Set color range from -1 (perfect negative) to 1 (perfect positive)

            % Add the variable names to the heatmap
            h.XDisplayLabels = DisplayLabels;
            h.YDisplayLabels = DisplayLabels;
            h.MissingDataColor = [1 1 1]; % RGB triplet for white color

            % Remove grid lines from the heatmap
            h.GridVisible = 'off'; % This removes the grid lines for the entire heatmap

            % Remove 'NaN' from the colorbar (legend)
            % Remove the frame of the color bar
            h.ColorbarVisible = 'on';  % Ensure the colorbar is visible
            % cb = colorbar; % Get the colorbar handle
            % set(cb, 'Box', 'off'); % Remove the box/frame around the colorbar

            % Remove small square below the color bar (NaN reserved square)
            set(h, 'MissingDataLabel', []); % Make sure there's no NaN square

            % Add title and labels
            if isempty(mode)
                mode4title = '';
                suffix4saving = '_heatmap.png';
            else
                mode4title = [' (', mode, ')'];
                suffix4saving = ['_' mode, '_heatmap.png'];
            end

            % DEFINE TITLE
            h.Title = ['// LV ', num2str(lv_idx), ' //' newline, 'Correlation of Latent Scores', mode4title];

            % % Save Figure
            % if ~exist(finalpath)
            %     mkdir(finalpath)
            % end

            % FIGURE NAME
            figure_name = fullfile(path, ['LV', num2str(lv_idx), '_LS', suffix4saving]);

            % SAVE FIGURE
            saveas(gcf, figure_name);
            close all 
            clear X
        end

end