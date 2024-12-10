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

    if contains(sectionTitle, 'Input')
        para = ['Sample: N = ', num2str(height(structData.Xs{1})), ' [', strjoin(unique(structData.DiagNames), ', '), ']'];
        add(chapter, para);
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

            if strcmp(fieldName, 'Xs') 
                para = Paragraph('Matrices [Xs]:');
                add(chapter, para)
                for x_idx = 1:numel(structData.Xs)
                    size = ['[', num2str(width(structData.Xs{x_idx})), ' features]'];
                    y = ['  > Matrix ', num2str(x_idx), ': ', structData.Xs_names{x_idx}, ' ', size]; 
                    para = Paragraph(y);
                    para.Style = {OuterMargin('18pt', '0pt', '0pt', '0pt')};
                    add(chapter, para)
                    clear para
                end 
                valueStr = [];

                % valueStr = [ newline, 'Test']
            elseif strcmp(fieldName, 'covariates') 
                if sum(cellfun(@isempty, structData.covariates)) == numel(structData.covariates)
                    para = Paragraph('Covariates: none');
                    add(chapter, para)
                else 
                    para = Paragraph('Covariates:');
                    add(chapter, para)
                    for cov_idx = 1:numel(structData.covariates)
                        if isempty(structData.covariates{cov_idx})
                            y = ['  > Matrix ', num2str(cov_idx), ': None'];
                            para = Paragraph(y);
                            para.Style = {OuterMargin('18pt', '0pt', '0pt', '0pt')};
                            add(chapter, para)
                        else
                            if ~isempty(structData.covariates_names{cov_idx})
                                y = ['  > Matrix ', num2str(cov_idx), ': ', strjoin(structData.covariates_names{cov_idx}, ', ')];
                                para = Paragraph(y);
                                para.Style = {OuterMargin('18pt', '0pt', '0pt', '0pt')};
                                add(chapter, para)
                            else
                                y = ['  > Matrix ', num2str(cov_idx), ': ', num2str(width(structData.covariates{cov_idx})), ' covariates'];
                                para = Paragraph(y);
                                para.Style = {OuterMargin('18pt', '0pt', '0pt', '0pt')};
                                add(chapter, para)
                            end

                        end
                    end
                end
                valueStr = [];

            elseif contains(fieldName, 'density') && isfield(structData, fieldName)
                density = structData.(fieldName);
                % Convert the cell array to a numeric array
                density = [density{:}];
                valueStr = ['[', num2str(density, '%d, ')];
                valueStr(end) = ']';  % Replace the last comma with a closing bracket

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
            % elseif contains(fieldName, 'DiagNames')
            %     valueStr = strjoin(unique(value), ', '); 
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

            if ~isempty(valueStr)
                try
                    fieldName(1) = upper(fieldName(1));
                    fieldName = strrep(fieldName, '_', ' ');
                    para = Paragraph([fieldName ': ' valueStr]);
                    add(chapter, para);
                catch
                    err
                end
            end
        end
    end
end
