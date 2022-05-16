function[varargout] = find(obj, variables, type)
%% ensembleMetadata.find  Locate the rows corresponding to specific variables in a state vector
% ----------
%   ... = obj.find(v)
%   ... = obj.find(variableNames)
%   ... = obj.find(-1)
%   Locate state vector rows/elements associated with the listed variables.
%   If the input is -1, selects all variables in the state vector. The
%   output of the method will depend on the number of variables selected.
%   See syntaxes below for details.
%
%   rows = obj.find(variable)
%   If a single variable is selected, returns the indices of all rows
%   associated with the variable. The output will be a column vector
%   matching the length of the variable in the state vector.
%
%   rowLimits = obj.find(variables)
%   If multiple variables are selected, returns the indices of the first
%   and last row for each variable. The output is a matrix with one row per
%   selected variable and two columns. The two columns list the first and last
%   row of each variable, respectively.
%
%   ... = obj.find(variables, type)
%   Indicate the type of output to return for the selected variables. See
%   syntaxes below for details.
%
%   rows = obj.find(variable, 'all'|'a'|0)
%   Return the indices of all the rows associated with a particular variable.
%   You can only specify a single variable when selecting this option.
%
%   startRows = obj.find(variables, 'start'|'s'|1)
%   Return the index of the first row for each of the listed variables.
%
%   endRows = obj.find(variables, 'end'|'e'|2)
%   Return the index of the last row for each of the listed variables.
%
%   rowLimits = obj.find(variables, 'limits'|'l'|3)
%   Return the indices of the first and the last row for each of the
%   selected variables.
% ----------

% Setup
header = "DASH:ensembleMetadata:find";
dash.assert.scalarObj(obj, header);

% Get variable indices
v = obj.variableIndices(variables, true, header);
nVars = numel(v);

% Default and parse type
if ~exist('type','var') || isempty(type)
    if nVars<=1
        type = 0;
    else
        type = 3;
    end
else
    switches = {["a","all"], ["s","start"], ["e","end"], ["l","limits"]};
    type = dash.parse.switches(type, switches, 1, 'type', 'allowed option', header);
end

% Only allow type 0 if a single variable is selected
if type==0 && nVars>1
    tooManyVariablesError;
end

% Get the index limits
limits = dash.indices.limits(obj.lengths);

% Return the requested output
if type==0
    rows = (limits(v,1):limits(v,2))';
    varargout = {rows};

elseif type==1
    startRows = limits(v,1);
    varargout = {startRows};

elseif type==2
    endRows = limits(v,2);
    varargout = {endRows};

elseif type==3
    limits = limits(v,:);
    varargout = {limits};
end

end