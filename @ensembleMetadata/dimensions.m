function[dimensions] = dimensions(obj, variables, type, cellOutput)
%% ensembleMetadata.dimensions  Return the dimensions associated with variables in a state vector ensemble
% ----------
%   dimensions = obj.dimensions
%   dimensions = obj.dimensions(-1)
%   Return the names of dimensions associated with each variable in the
%   state vector.
%
%   dimensions = obj.dimensions(v)
%   dimensions = obj.dimensions(variableNames)
%   Return the names of dimensions associated with the specified state
%   vector variables.
%
%   dimensions = obj.dimensions(..., type)
%   dimensions = obj.dimensions(..., 0|'a'|'all'|[])
%   dimensions = obj.dimensions(..., 1|'s'|'state')
%   dimensions = obj.dimensions(..., 2|'e'|'ens'|'ensemble')
%   Specify the type of dimension to return for each variable. Options are
%   all dimensions, state dimensions, or ensemble dimensions. By default,
%   returns all dimensions for each variable.
%
%   dimensions = obj.dimensions(..., type, cellOutput)
%   dimensions = obj.dimensions(..., type, true|'c'|'cell')
%   dimensions = obj.dimensions(..., type, false|'d'|'default')
%   Specify whether output should always be organized in a cell. If false
%   (default), dimensions for a single variable are returned as a string row
%   vector. If true, dimensions for a single variable are returned as a
%   string row vector within a scalar cell. Dimensions for multiple variables
%   are always returned as a cell vector of string row vectors.
% ----------

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

% Get the dimension names
for k = 1:numel(vars)
    v = vars(k);
    if type==0 || type==1
        stateDims = [obj.stateDimensions{v}];
    end
    if type==0 || type==2
        s = obj.couplingSet(v);
        ensDims = [obj.ensembleDimensions{s}];
    end

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