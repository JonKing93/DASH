function[meta] = columns(obj, cols, varNames, dims, alwaysStruct)
%% Returns the metadata at a particular column across the ensemble.
%
% metaStruct = obj.columns( cols )
% Returns a structure with the metadata at the specified ensemble members
% for each variable and dimension in the state vector ensemble.
%
% metaStruct = obj.columns( cols, varNames )
% Returns metadata for the specified variables for all dimensions.
%
% metaStruct = obj.columns( cols, varNames, dimNames )
% Returns metadata for the specified variables and dimensions.
%
% metaStruct = obj.columns( cols, varNames, dimCell )
% Specify different dimensions for different variables.
%
% meta = obj.columns( cols, varName, dimName )
% Return metadata for a single variable and single dimension directly as an
% array.
%
% metaStruct = obj.columns( cols, varName, dimName, alwaysStruct )
% Specify to always return output as a structure.
%
% ----- Inputs -----
%
% cols: The indices of the columns (ensemble members) for which to return
%    metadata. Either a vector of linear indices, or a logical vector. If a
%    logical vector, must have one element per ensemble member.
%
% varNames: A list of variables in the state vector ensemble. A string
%    vector or cellstring vector.
%
% dimName: A list of dimension names. A string vector or cellstring vector.
%
% dimCell: A cell vector with one element per listed dimension name. Each
%    element contains a list of dimension names for the corresponding
%    variable.
%
% alwaysStruct: A scalar logical that indicates if metadata should always
%    be returned as a structure (true) or not (false -- default)
%
% ----- Outputs -----
%
% metaStruct: A structure holding metadata at the specified column for the
%    variables and dimensions.
%
% meta: An array with metadata for the specified variable and dimension.
%    Has one row per specified ensemble member.

% Error check the columns
dash.assert.vectorTypeN(cols, 'numeric', [], 'cols');
cols = dash.assert.indices(cols, 'cols', obj.nEns, 'the number of ensemble members');

% Default variable names. Error check. Indices
if ~exist('varNames','var') || isempty(varNames)
    varNames = obj.variableNames;
end
varNames = dash.assert.strlist(varNames, 'varNames');
v = dash.assert.strsInList(varNames, obj.variableNames, 'varNames', 'variables in the state vector');
nVars = numel(v);

% Default dimension names. Error check. Propagate strings into cells
if ~exist('dims','var') || isempty(dims)
    dims = obj.dims(v);
elseif ~iscell(dims)
    dims = dash.assert.strlist(dims, 'dims');
    dims = repmat({dims}, [nVars,1]);
else
    for d = 1:numel(dims)
        dims{d} = dash.assert.strlist(dims{d}, sprintf('Element %.f of dimCell', d));
    end
end
dash.assert.vectorTypeN(dims, 'cell', nVars, 'dims');

% Default and error check alwaysStruct
if ~exist('alwaysStruct','var') || isempty(alwaysStruct)
    alwaysStruct = false;
end
dash.assert.scalarType(alwaysStruct, 'alwaysStruct', 'logical', 'logical');

% Initialize the output structure
meta = struct();

% Get the metadata for each variable
for k = 1:nVars
    var = varNames(k);
    indices = repmat({cols}, [1, numel(dims{k})]);
    meta.(var) = obj.variable(var, dims{k}, 'ensemble', indices, true);
end

% Optionally return array
if ~alwaysStruct && nVars==1 && numel(dims{1})==1
    meta = meta.(var).(dims{1});
end

end