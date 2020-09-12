function[input, wasCell] = parseInputCell(input, nDims, name)
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
%
% wasCell: Scalar logical. Whether the input was a cell or not

if nDims>1 || iscell(input)
    dash.assertVectorTypeN(input, 'cell', nDims, name);
    wasCell = true;
else
    input = {input};
    wasCell = false;
end

end