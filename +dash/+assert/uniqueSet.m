function[] = uniqueSet(input, inputName, header)

if ~exist('header','var') || isempty(header)
    header = "DASH:assert:uniqueSet";
end

% Test for a unique set
[isunique, repeats] = dash.is.uniqueSet(input);

% If not unique, throw informative error
if ~isunique
    value = input(repeats(1));
    
    if isnumeric(value)
        format = '%.f';
    else
        format = '%s';
    end
    
    id = sprintf('%s:duplicateValues', header);
    message = sprintf('%s "%s" is repeated multiple times. (%ss %s)', ...
        inputName, format, inputName, dash.string.list(repeats));
    error(id, message, value); %#ok<SPERR>
end

end