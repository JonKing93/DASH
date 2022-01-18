function[varargout] = overlap(obj, variables, allowOverlap)
%% stateVector.overlap  Set whether ensemble members of variable can use overlapping, non-duplicate information
% ----------
%   allowOverlap = obj.overlap
%   allowOverlap = obj.overlap([])
%   allowOverlap = obj.overlap(0)
%   Returns the overlap permissions for all variables in the state vector.
%
%   allowOverlap = obj.overlap(v)
%   allowOverlap = obj.overlap(variableNames)
%   Returns the overlap permissions for the indicated variables.
%
%   obj = obj.overlap(v, allowOverlap)
%   obj = obj.overlap(variableNames, allowOverlap)
%   Specifies whether the ensemble members of the indicated variables can
%   use overlapping (but non-duplicate) information. Default is to prohibit
%   overlap. Set to true to enable overlap for the indicated variables.
% ----------
%   Inputs:
%       v (logical vector [nVariables] | vector, linear indices [nInput]): The
%           indices of the variables that should have overlap permissions
%           adjusted.
%       variableNames (string vector [nInput]): The names of the variables that
%           should have overlap permissions adjusted.
%       allowOverlap (scalar logical | logical vector [nInput]): The overlap
%           permissions for the input variables. Set to true to allow
%           overlap. Set to false (default) to prohibit overlap. If scalar,
%           applies the same setting to all input variables. If a vector,
%           must have one element per input variable, and applies the
%           indicated setting to each variable.
%
%   Outputs:
%       allowOverlap (logical vector [nVariables | nInput]): Lists the current 
%           overlap permissions of the indicated variables. True if overlap
%           is allowed, false if overlap is prohibited.
%       obj (scalar stateVector object): The stateVector object with
%           updated overlap permissions.
%
% <a href="matlab:dash.doc('stateVector.overlap')">Documentation Page</a>

% Setup
header = "DASH:stateVector:overlap";
dash.assert.scalarObj(obj, header);

% Return all permissions
if ~exist('variables','var') || isempty(variables) || isequal(variables,0)
    assert(~exist('allowOverlap','var'), 'MATLAB:TooManyInputs', 'Too many input arguments.');
    varargout = {obj.allowOverlap};
    return;
end

% Additional error checking when setting values
allowRepeats = true;
if exist('allowOverlap','var') && ~isempty(allowOverlap)
    allowRepeats = false;
    obj.assertEditable;
end

% Parse variable indices
v = obj.variableIndices(variables, allowRepeats, header);

% Return values
if allowRepeats
    varargout = {obj.allowOverlap(v)};

% Set values
else
    dash.assert.logicalSwitches(allowOverlap, numel(v), 'allowOverlap', header);
    obj.allowOverlap(v) = allowOverlap;
end

end