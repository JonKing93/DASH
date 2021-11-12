function[] = uniqueSet(input, inputName, header)

if ~exist('header','var') || isempty(header)
    header = "DASH:assert:uniqueSet";
end

[~, uniqElements, locInInput] = unique(input);
if numel(uniqElements) < numel(input)
    allElements = 1:numel(input);
    repeat = find(~ismember(allElements, uniqElements), 1);
    repeat = find(locInInput==locInInput(repeat));
    value = input(repeat(1));
    
    if isnumeric(value)
        format = '%.f';
    else
        format = '%s';
    end
    
    id = sprintf('%s:duplicateValues', header);
    message = sprintf('%s "%s" is repeated multiple times. (%ss %s)', ...
        inputName, format, inputName, dash.string.list(repeat));
    error(id, message, value); %#ok<SPERR>
end

end