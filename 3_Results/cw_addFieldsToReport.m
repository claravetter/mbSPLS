function cw_addFieldsToReport(chapter, structData, sectionTitle, fields)
    import mlreportgen.report.*
    import mlreportgen.dom.*
    
    % Create a section with the title as a paragraph
% Ensure sectionTitle is a string or character array
    if ischar(sectionTitle) || isstring(sectionTitle)
        sectTitlePara = Paragraph(char(sectionTitle)); % Convert to char in case it's a string
        sectTitlePara.Style = {Bold(true)};
        add(chapter, sectTitlePara);
    else
        error('sectionTitle must be a string or character array');
    end
    
    % Get the field names
    % fields = fieldnames(structData);
    for i = 1:numel(fields)
        fieldName = fields{i};
        % Check if the field is a structure itself
        if isfield(structData, fieldName) && isstruct(structData.(fieldName))
            % Recursively add nested fields
            addFieldsToReport(chapter, structData.(fieldName), fieldName);
        elseif isfield(structData, fieldName) && ~isstruct(structData.(fieldName))
            % Add a paragraph for each field
            if contains(fieldName, 'mult_test')
                value = structData.final_merge.(fieldName);
            else
                value = structData.(fieldName);
            end

            if contains(fieldName, 'Xs') 
                x = 'Matrices: '; yy = cellstr(''); 
                for x_idx = 1:numel(structData.Xs)
                    size = ['[', num2str(height(structData.Xs{x_idx})), 'x', num2str(width(structData.Xs{x_idx})), ']'];
                    y = {[newline, '    Matrix ', num2str(x_idx), ': ', structData.Xs_names{x_idx}, ' ', size]}; 
                    yy = append(yy, y);
                end 
                valueStr = string(append(x, yy));

                % valueStr = [ newline, 'Test']
                        
            elseif contains(fieldName, 'covariates')
                idx = [];
                for v = 1:numel(value)
                    if isempty(value{v})
                        idx{v} = '[]';
                    else
                        idx{v} = [num2str(height(value{v})), 'x', num2str(width(value{v})), ' ', class(value{v})];
                    end
                end
                valueStr = ['[', strjoin(idx, '; '), ']'];

            elseif contains(fieldName, 'covariates_names') && ~isempty(covariates_names)
                valueStr = strjoin(value, ', ');

            elseif contains(fieldName, 'framework')
                switch value
                    case 1
                        valueStr = 'Nested cross-validation'; 
                    case 2
                        valueStr = 'Random hold-out splits';
                    case 3
                        valueStr = 'LOSOCV'; 
                    case 4
                        valueStr = 'Random split-half';
                end 
            elseif contains(fieldName, 'statistical_testing')
                switch value
                    case 1
                        valueStr = 'Counting Method'; 
                    case 2
                        valueStr = 'AUC method';
                end 
            elseif contains(fieldName, 'DiagNames')
                valueStr = strjoin(unique(value), ', '); 
            elseif isstring(value) || ischar(value)
                valueStr = value; 
            elseif (isnumeric(value) && numel(value) > 1) || (iscellstr(value) && numel(value) > 1)
                valueStr = [num2str(height(value)), 'x', num2str(width(value)), ' ', class(value)];
            elseif isnumeric(value) && numel(value) == 1
                valueStr = num2str(value);
            elseif iscellstr(value) && numel(value) == 1
                valueStr = string(value); 
            elseif iscell(value) && ~iscellstr(value)
                valueStr = num2str(cell2mat(value));
            end 

            try
                fieldName(1) = upper(fieldName(1));
                fieldName = strrep(fieldName, '_', ' ');
                para = Paragraph([fieldName ': ' valueStr]);
            catch
                err
            end
            add(chapter, para);
        end
    end
end
