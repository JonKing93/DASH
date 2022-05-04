function[variableNames] = variables(obj, varargin)
%% ensemble.variables  Return the names of variables in an ensemble
% ----------
%   variableNames = obj.variables
%   Returns the ordered list of variables in the ensemble. The index of
%   each variable in the list corresponds to the index of the variable in
%   the ensemble. If the "useVariables" command has been applied to the
%   ensemble, only returns the names and indices of the variables being
%   used by the ensemble object.
%
%   variableNames = obj.variables(scope)
%   variableNames = obj.variables(false|"u"|"used")
%   variableNames = obj.variables(true|"f"|"file")
%   Indicate the scope in which to return variable names. If
%   false|"u"|"used", behaves identically to the previous syntax and
%   returns the names of variables being used. If true|"f"|"file", returns
%   the names of all variables saved in the .ens file.
%
%   variableNames = obj.variables(v)
%   variableNames = obj.variables(-1)
%   Returns the list of variables at the specified variable indices. The
%   order of variables in the list corresponds to the order of input
%   indices. Variable indices are interpreted in the context of variables
%   being used by the ensemble. If the index is -1, selects all used
%   variables.
%
%   variableNames = obj.variables(v, scope)
%   variableNames = obj.variables(scope, v)
%   Indicate the scope in which to interpret variable indices. If
%   false|"u"|"unused", behaves identically to the previous syntax and
%   interprets indices in the context of variables being used by the
%   ensemble. If true|"f"|"file", interprets indices in the context of
%   variables saved in the .ens file. If the index is -1, returns the names
%   of all variables within the appropriate scope.
% ----------
%   Inputs:
%       v (-1 | vector, linear indices): The indices of variables in the
%           ensemble whose names should be returned. If -1, selects all
%           variables.
%       scope (string scalar | logical scalar): The scope in which to
%           interpret indices and return variable names
%           ["used"|"u"|true (default)]: Return names relative to the set
%               of variables being used by the ensemble object.
%           ["file"|"f|false]: Return names relative to the set of all
%               variables stored in the .ens file.
%
%   Outputs:
%       variableNames (string vector): The names of the specified variables
%
% <a href="matlab:dash.doc('ensemble.variables')">Documentation Page</a>

% Setup
header = "DASH:ensemble:variables";
dash.assert.scalarObj(obj, header);
if nargin>3
    dash.error.tooManyInputs;
end

% If the user provided inputs, identify the first
nInputs = numel(varargin);
if nInputs>0
    if islogical(varargin{1}) || dash.is.string(varargin{1})
        scope = varargin{1};
    elseif isnumeric(varargin{1})
        v = varargin{1};
    else
        id = sprintf('%s:invalidInput', header);
        error(id, ['The first input must either be -1, a set of variable indices, ',...
            'or a scope selector ("used", "file", "u", "f", true, or false).']);
    end
end

% Default and parse variable indices
if ~exist('v','var')
    if nInputs<2
        v = -1;
    elseif isnumeric(varargin{2})
        v = varargin{2};
    else
        id = sprintf('%s:invalidInput', header);
        error(id, ['Since the first input is a scope selector, the second input ',...
            'must be a set of variable indices or -1.']);
    end
end

% Default and parse scope
if ~exist('scope','var')
    if nInputs<2
        scope = "used";
    elseif islogical(varargin{2}) || dash.is.string(varargin{2})
        scope = varargin{2};
    else
        id = sprintf('%s:invalidInput', header);
        error(id, ['Since the first input is numeric, the second input must ',...
            'be a scope selector ("used", "file", "u", "f", true, or false).']);
    end
end

% Error check, get indices
v = obj.variableIndices(v, scope, header);

% Return names
variableNames = obj.variables_(v);

end