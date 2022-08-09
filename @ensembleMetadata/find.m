function[varargout] = find(obj, variables, type)
%% ensembleMetadata.find  Locate the rows corresponding to specific variables in a state vector
% ----------
%   ... = <strong>obj.find</strong>(variableNames)
%   ... = <strong>obj.find</strong>(v)
%   ... = <strong>obj.find</strong>(-1)
%   Locate state vector rows/elements associated with the listed variables.
%   If the input is -1, selects all variables in the state vector. The
%   output of the method will depend on the number of variables selected.
%   See syntaxes below for details.
%
%   rows = <strong>obj.find</strong>(variable)
%   If a single variable is selected, returns the indices of all rows
%   associated with the variable. The output will be a column vector
%   matching the length of the variable in the state vector.
%
%   rowLimits = <strong>obj.find</strong>(variables)
%   If multiple variables are selected, returns the indices of the first
%   and last row for each variable. The output is a matrix with one row per
%   selected variable and two columns. The two columns list the first and last
%   row of each variable, respectively.
%
%   ... = <strong>obj.find</strong>(variables, type)
%   Indicate the type of output to return for the selected variables. See
%   syntaxes below for details.
%
%   rows = <strong>obj.find</strong>(variable, 'all'|'a'|0)
%   Return the indices of all the rows associated with a particular variable.
%   You can only specify a single variable when selecting this option.
%
%   startRows = <strong>obj.find</strong>(variables, 'start'|'s'|1)
%   Return the index of the first row for each of the listed variables.
%
%   endRows = <strong>obj.find</strong>(variables, 'end'|'e'|2)
%   Return the index of the last row for each of the listed variables.
%
%   rowLimits = <strong>obj.find</strong>(variables, 'limits'|'l'|3)
%   Return the indices of the first and the last row for each of the
%   selected variables.
% ----------
%   Inputs:
%       variableNames (string vector): The names of the variables for which
%           to return rows.
%       v (-1 | logical vector | vector, linear indices): The indices of
%           the variables in the state vector for which to return rows. If
%           -1, selects all variables. If a logical vector, must have one
%           element per variable in the state vector.
%       type (string scalar | scalar positive integer): Indicates the type
%           of output to return for the listed variables.
%           ["all"|"a"|0]: Returns the indices of all of the rows
%               associated with a variable. This is the default when a
%               single variable is selected, and this option can only be
%               used for a single variable.
%           ["start"|"s"|1]: Returns the starting row of each variable
%           ["end"|"e"|2]: Returns the final row of each variable
%           ["limits"|"l"|3]: Returns the first and last row of each
%               variable. This is the default output when multiple
%               variables are selected.
%
%   Outputs:
%       rows (vector, linear indices): The indices of all the state vector
%           rows associated with a particular variable.
%       rowLimits (matrix [nVariables x 2], linear indices): The first and
%           the last row for each of the listed variables. The first column
%           lists the starting rows, and the second column lists the ending rows.
%       startRows (vector, linear indices [nVariables]): The first state
%           vector row for each of the listed variables.
%       endRows (vector, linear indices [nVariables]): The final state
%           vector row of each of the listed variables.
%
% <a href="matlab:dash.doc('ensembleMetadata.find')">Documentation Page</a>

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
    tooManyVariablesError(obj, v, header);
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

% Error message
function[] = tooManyVariablesError(obj, v, header)
variables = obj.variables_(v);
variables = dash.string.list(variables);
id = sprintf('%s:tooManyVariables', header);
ME = MException(id, ['You can only select a single variable when returning ',...
    'all rows as output, but you have specified %.f variables (%s).'], ...
    numel(v), variables);
throwAsCaller(ME);
end