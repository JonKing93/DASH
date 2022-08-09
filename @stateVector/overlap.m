function[varargout] = overlap(obj, variables, allowOverlap)
%% stateVector.overlap  Set whether ensemble members of variable can use overlapping, non-duplicate information
% ----------
%   allowOverlap = <strong>obj.overlap</strong>
%   allowOverlap = <strong>obj.overlap</strong>(-1)
%   Return the overlap permissions of all variables in the state vector.
%
%   allowOverlap = <strong>obj.overlap</strong>(v)
%   allowOverlap = <strong>obj.overlap</strong>(variableNames)
%   Returns the overlap permissions for the indicated variables.
%
%   obj = <strong>obj.overlap</strong>(variables, allowOverlap)
%   obj = <strong>obj.overlap</strong>(variables, true|"a"|"allow")
%   obj = <strong>obj.overlap</strong>(variables, false|"p"|"prohibit")
%   Specify whether the ensemble members of indicated variables can use 
%   overlapping (but non-duplicate) information. Default is to prohibit
%   overlap.
% ----------
%   Inputs:
%       v (logical vector | vector, linear indices [nVariables] | -1): The
%           indices of the variables for which to set or return overlap
%           permissions. If -1, selects all variables in the state vector.
%       variableNames (string vector [nVariables]): The names of the variables that
%           should have overlap permissions adjusted.
%       allowOverlap (scalar logical | logical vector [nInput]): The overlap
%           permissions to use for the listed variables.
%           [true|"a"|"allow"]: Allow ensemble members to use overlapping data
%           [false|"p"|"prohibit"]: Prohibit overlapping ensemble members
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

% Allow or prohibit repeat variables for returning/setting values
if ~exist('allowOverlap','var')
    allowRepeats = true;
else
    allowRepeats = false;
end

% Parse variable indices
if ~exist('variables','var')
    variables = -1;
end
v = obj.variableIndices(variables, allowRepeats, header);

% Return values
if allowRepeats
    varargout = {obj.allowOverlap(v)};

% Require editable if setting values
else
    obj.assertEditable;
    allowOverlap = dash.parse.switches(allowOverlap, {["p","prohibit"],["a","allow"]},...
        numel(v), 'allowOverlap', 'recognized setting', header);
    obj.allowOverlap(v) = allowOverlap;
    varargout = {obj};
end

end