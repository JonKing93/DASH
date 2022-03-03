function[input, wasCell] = inputOrCell(input, nEls, name, header)
%% dash.parse.inputOrCell  Parse inputs that are either cell vector of arrays, or a single array
% ----------
%   [input, wasCell] = dash.parse.inputOrCell(input, nEls)
%   Parses an input that can either be a cell vector of arrays, or a single
%   array. If multiple array are required, ensures the input is a cell
%   vector with the correct number of elements. If a single array is
%   required and the input is an array, returns the array in a cell scalar.
%   Also returns whether the input was a cell vector or direct array.
%
%   ... = dash.parse.inputOrCell(input, nEls, name, header)
%   Customize thrown error messages and IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       nEls (numeric scalar): The number of arrays required.
%       name (string scalar): A name to refer to the input in error
%           messages. Default is "input".
%       header (string scalar): Header for thrown error IDs. Default is
%           "DASH:parse:inputOrCell"
%
%   Outputs:
%       input (cell vector): The input array stored in a cell vector
%       wasCell (scalar logical): True if the input was a cell vector.
%           Otherwise, false.
%
% <a href="matlab:dash.doc('dash.parse.inputOrCell')">Documentation Page</a>

% Parse
try
    if nEls>1 || iscell(input)
        dash.assert.vectorTypeN(input, 'cell', nEls, name, header);
        wasCell = true;
    else
        input = {input};
        wasCell = false;
    end

% Minimize error stacks
catch ME
    throwAsCaller(ME);
end

end