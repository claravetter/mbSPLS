function [] = cw_create_table_for_pdf(chapter, T)
    import mlreportgen.report.*
    import mlreportgen.dom.*

    add(chapter, Paragraph(' '));  % Add an empty paragraph for spacing
 % Create a report table
    reportTable = Table();
        % Optionally, set table properties
    reportTable.Border = 'none';  % Remove outer border
    reportTable.ColSep = 'none';  % Remove column separators
    reportTable.RowSep = 'solid';  % Remove row separators

    colWidths = {'0.5in', '1.5in', '1.5in', '0.5in'};  % Adjust the width for each column

    % Add header row to the report table using the variable names
    headerRow = TableRow();
    for k = 1:width(T)
        headerEntry = TableEntry(T.Properties.VariableNames{k});
        headerEntry.Style = {Bold(true), ...   % Make header bold
            BackgroundColor('lightgray'), ...  % Header background color
            HAlign('center'), ...  % Center align text
            Width(colWidths{k}), ...  % Set column width (adjust to make the table narrower)
            OuterMargin('2pt', '5pt', '5pt', '2pt')};  % Add some margin to the cells
        append(headerRow, headerEntry);
    end
    append(reportTable, headerRow);  % Add the header row to the table

    % Add data rows to the report table
    for i = 1:height(T)
        row = TableRow();
        for j = 1:width(T)
            % Convert each cell to a string for the table entry
            cellData = T{i, j};
            entry = TableEntry(num2str(cellData));
            switch j
                case 1
                    position = 'center';
                case {2,3,4}
                    position = 'left';
            end
            entry.Style = {HAlign(position), ...  % Left align the text
                Width(colWidths{k}), ...  % Set the same width for all cells
                OuterMargin('2pt', '5pt', '5pt', '2pt')};  % Add margin to the cells            
            append(row, entry);
        end
        append(reportTable, row);  % Add the row to the table
    end



    % Add the report table to the chapter
    add(chapter, reportTable);
end