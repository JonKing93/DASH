function[dimensions] = dimensions(obj, variables, type, cellOutput)
%% ensembleMetadata.dimensions  Return the dimensions associated with variables in a state vector ensemble
% ----------
%   dimensions = <strong>obj.dimensions</strong>
%   dimensions = <strong>obj.dimensions</strong>(-1)
%   Return the names of dimensions associated with each variable in the
%   state vector.
%
%   dimensions = <strong>obj.dimensions</strong>(v)
%   dimensions = <strong>obj.dimensions</strong>(variableNames)
%   Return the names of dimensions associated with the specified state
%   vector variables.
%
%   dimensions = <strong>obj.dimensions</strong>(..., type)
%   dimensions = <strong>obj.dimensions</strong>(..., 0|'a'|'all'|[])
%   dimensions = <strong>obj.dimensions</strong>(..., 1|'s'|'state')
%   dimensions = <strong>obj.dimensions</strong>(..., 2|'e'|'ens'|'ensemble')
%   Specify the type of dimension to return for each variable. Options are
%   all dimensions, state dimensions, or ensemble dimensions. By default,
%   returns all dimensions for each variable.
%
%   dimensions = <strong>obj.dimensions</strong>(..., type, cellOutput)
%   dimensions = <strong>obj.dimensions</strong>(..., type, true|'c'|'cell')
%   dimensions = <strong>obj.dimensions</strong>(..., type, false|'d'|'default')
%   Specify whether output should always be organized in a cell. If false
%   (default), dimensions for a single variable are returned as a string row
%   vector. If true, dimensions for a single variable are returned as a
%   string row vector within a scalar cell. Dimensions for multiple variables
%   are always returned as a cell vector of string row vectors.
% ----------
%   Inputs:
%       variableNames (string vector): The names of variables for which to
%           return dimension names.
%       v (-1 | logical vector | vector, linear indices): The indices of
%           variables in the state vector for which to return dimension
%           names. If -1, selects all variables. If a logical vector, must
%           have one element per variable in the state vector.
%       type (string scalar | scalar positive integer): Indicates which
%           types of dimension names to return
%           [0|"all"|"a" (default)]: Returns the names of all dimensions for each variable
%           [1|"state"|"s"]: Returns the names of state dimensions.
%           [2|"ensemble"|"ens"|"e"]: Returns the names of ensemble dimensions
%       cellOutput (string scalar | scalar logical): Whether to always
%           return output as a cell.
%           ["cell"|"c"|true]: Always returns outputs in a cell, even the
%               dimensions for a single variable.
%           ["default"|"d"|false]: Dimensions for a single variable are
%               returned directly as a string vector.
%
%   Outputs:
%       dimensions (string vector | cell vector [nVariables] {string vector}):
%           The names of the dimensions for the listed variables. If a
%           single variable is listed and cellOutput is on the default
%           setting, a string vector with one element per listed dimension.
%           If multiple variables are listed, a cell vector with one
%           element per listed variable. Each element holds the names of the
%           dimensions for a listed variable.
%
% <a href="matlab:dash.doc('ensembleMetadata.dimensions')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:dimensions";
dash.assert.scalarObj(obj, header);

% Parse dimension type
if ~exist('type','var') || isempty(type)
    type = 0;
else
    switches = {["a","all"],["s","state"],["e","ens","ensemble"]};
    type = dash.parse.switches(type, switches, 1, 'type', 'recognized dimension type', header);
end

% Parse cell output
if ~exist('cellOutput','var') || isempty(cellOutput)
    cellOutput = false;
else
    switches = {["d","default"], ["c","cell"]};
    cellOutput = dash.parse.switches(cellOutput, switches, 1, 'cellOutput',...
        'allowed option', header);
end

% Parse variable indices
if ~exist('variables','var') 
    variables = -1;
end
vars = obj.variableIndices(variables, true, header);

% Preallocate
nVars = numel(vars);
dimensions = cell(nVars, 1);

% Get the state and ensemble names
for k = 1:numel(vars)
    v = vars(k);
    if type==0 || type==1
        stateDims = [obj.stateDimensions{v}];
    end
    if type==0 || type==2
        s = obj.couplingSet(v);
        ensDims = [obj.ensembleDimensions{s}];
    end

    % Get the requested dimension names
    if type==0
        dimensions{v} = unique([stateDims, ensDims]);
    elseif type==1
        dimensions{v} = stateDims;
    else
        dimensions{v} = ensDims;
    end
end

% Optionally extract single variable from cell
if numel(dimensions)==1 && ~cellOutput
    dimensions = dimensions{1};
end

end