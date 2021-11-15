function[] = uniqueSet(input, inputName, header)
%% dash.assert.uniqueSet  Throw error if vector has repeated values
% ----------
%   dash.assert.uniqueSet(input)
%   Tests if an input vector has repeated values. If so, throws an error.
%
%   dash.assert.uniqueSet(input, inputName, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       input: The input vector being tested
%       inputName (string scalar): The name of the input
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('dash.assert.uniqueSet')">Documentation Page</a>

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