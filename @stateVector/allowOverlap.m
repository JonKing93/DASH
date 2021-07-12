function[obj] = allowOverlap(obj, varNames, overlap)
%% Specify whether ensemble members for the listed variables are allowed to
% use overlapping (but non-duplicate) information.
%
% obj = obj.allowOverlap(varNames, overlap)
%
% ----- Inputs -----
%
% varNames: The names of variables for which to set overlap options. A
%    string vector or cellstring vector.
% 
% overlap: A logical indicating whether to allow ensemble members to use
%    overlapping information (true) or not (false -- default). Use a scalar
%    logical to specify the same option for all listed variables. Use a
%    logical vector to specify different options for different variables
%    listed in varNames.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check, variable indices, editable
obj.assertEditable;
v = obj.checkVariables(varNames);

% Error check overlap
if ~islogical(overlap)
    error('overlap must be a logical');
elseif ~isscalar(overlap)
    dash.assert.vectorTypeN(overlap, [], numel(v), 'Since overlap is not a scalar, it');
end

% Update
obj.overlap(v) = overlap;

end