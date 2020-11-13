function[meta] = row(obj, row, dims, alwaysStruct)
%% Returns the metadata at a particular row down the state vector.
%
% metaStruct = obj.row( row )
% Returns a structure with the metadata at the specified row for each
% dimension.
%
% meta = obj.row( row, dim )
% Returns metadata for a particular dimension at the specified row.
%
% meta = obj.row( row, 0)
% Returns the name of the state vector variable at the specified row.
%
% metaStruct = obj.row(row, dims)
% Returns metadata for multiple requested dimensions.
%
% metaStruct = obj.row(row, dim, alwaysStruct)
% Specify if metadata should always be returned as a structure.
%
% ----- Inputs -----
%
% row: A scalar integer indicating one of the rows down the state vector.
%
% dim: The name of a dimension. A string.
%
% dims: The names of multiple dimensions. A string vector or cellstring
%    vector.
%
% alwaysStruct: A scalar logical indicating if metadata should always be
%    returned as a structure (true) or not (false -- default).
%
% ----- Outputs -----
%
% meta: The metadata at the row for a particular dimension.
%
% metaStruct: The metadata at the row for all requested dimesions.

% Error check
dash.assertScalarType(row, 'row', 'numeric', 'numeric');
assert(ismember(row, 1:obj.varLimit(end)), sprintf('row must be an integer on the interval [1, %.f]', obj.varLimit(end)));

% Find the variable associated with the row and place the row within the
% variable's size
v = obj.varLimit(:,1)<=row & obj.varLimit(:,2)>=row;
varName = obj.variableNames(v);
varRow = row - obj.varLimit(v,1) + 1;

% Default output dimensions
returnName = false;
if ~exist('dims','var') || isempty(dims)
    dims = obj.dims{v};
    returnName = true;
elseif isequal(dims, 0)
    dims = [];
    returnName = true;
end

% Default and error check structure output
if ~exist('alwaysStruct','var') || isempty(alwaysStruct)
    alwaysStruct = false;
end
dash.assertScalarType(alwaysStruct, 'alwaysStruct', 'logical', 'logical');

% Get the metadata structure for the dimensions. (This will also error
% check the dimension names)
if ~isempty(dims)
    dims = dash.assertStrList(dims, 'dims');
    indices = repmat( {varRow}, [1, numel(dims)]);
    meta = obj.variable(varName, dims, 'state', indices, true);
elseif alwaysStruct
    meta = struct();
end

% Add in the variable name
if returnName
    meta.stateVectorVariable = varName;
    meta = orderfields(meta, ["stateVectorVariable";dims(:)]);
end

% Optionally return as array
if ~alwaysStruct
    names = string(fields(meta));
    nFields = numel(names);
    if nFields == 1
        meta = meta.(names);
    end
end

end