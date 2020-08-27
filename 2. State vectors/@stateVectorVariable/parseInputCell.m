function[input] = parseInputCell(input, nDims, name)
%% Parses inputs that may either be an input, or a cell vector of inputs.
% Returns the input as a cell. Throws a custom error message if cell
% vectors are incorrect.
%
% input = stateVectorVariable.parseInputCells(input, nDims, name)
%
% ----- Inputs -----
%
% input: The input being parsed
%
% nDims: The number of input dimensions.
%
% name: The name of the input. A string.
%
% ----- Outputs -----
%
% input: The input as a cell

if nDims>1 || iscell(input)
    dash.assertVectorTypeN(input, 'cell', nDims, name);
else
    input = {input};
end

end