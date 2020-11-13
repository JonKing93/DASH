function[meta] = column(col, varNames, dims, alwaysStruct)
%% Returns the metadata at a particular column across the ensemble.
%
% metaStruct = obj.column( col )
% Returns a structure with the metadata at the specified ensemble member
% for each variable and dimension in the state vector ensemble.
%
% metaStruct = obj.column( col, varNames )
% Returns metadata for the specified variables for all dimensions.
%
% metaStruct = obj.column( col, varNames, dimNames )
% Returns metadata for the specified variables and dimensions.
%
% metaStruct = obj.column( col, varNames, dimCell )
% Specify different dimensions for different variables.
%
% meta = obj.column( col, varName, dimName )
% Return metadata for a single variable and single dimension directly as an
% array.
%
% metaStruct = obj.column( col, varName, dimName, alwaysStruct )
% Specify to always return output as a structure.
%
% ----- Inputs -----
%
% col: A scalar integer indicating one of the columns (ensemble members) in
%    the state vector ensemble.
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

% Default variable names. Error check. Indices
if ~exist('varNames','var') || isempty(varNames)
    varNames = obj.variableNames;
end
varNames = dash.assertStrList(varNames, 'varNames');
v = dash.checkStrsInList(varNames, obj.variableNames, 'varNames', 'variables in the state vector');
nVars = numel(v);

% Default dimension names. Error check. Propagate strings into cells
if ~exist('dims','var') || isempty(dims)
    dims = obj.dims(v);
elseif ~iscell(dims)
    dash.assertStrList(dims, 'dims');
    dims = repmat({dims}, [nVars,1]);
else
    for d = 1:numel(dims)
        dims{d} = dash.assertStrList(dims{d}, sprintf('Element %.f of dimCell', d));
    end
end
dash.assertVectorTypeN(dims, 'cell', nVars, 'dims');

% Default and error check alwaysStruct
if ~exist('alwaysStruct','var') || isempty(alwaysStruct)
    alwaysStruct = false;
end
dash.assertScalarType(alwaysStruct, 'alwaysStruct', 'logical', 'logical');

% Initialize the output structure
meta = struct();

% Get the metadata for each variable
for k = 1:nVars
    var = varNames(v(k));
    indices = repmat({col}, [1, numel(dims{k})]);
    meta.(var) = obj.variable(var, dims{k}, 'ensemble', indices, true);
end

% Optionally return array
if ~alwaysStruct && nVars==1 && numel(dims{1})==1
    meta = meta.(var).(dims{1});
end

end