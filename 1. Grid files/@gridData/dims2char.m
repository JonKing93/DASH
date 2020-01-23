function[dimChar] = dims2char( dims )
% Converts a string array of dimension names to a comma delimited char
dimChar = char(dims(1));
for k = 2:numel(dims)
    dimChar = [dimChar,',',char(dims(k))]; %#ok<AGROW>
end
end