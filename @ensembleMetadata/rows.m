function[meta] = rows(obj, rows, dims, fullStruct)
%% Returns the metadata at a particular row down the state vector.
%
% varStruct = obj.rows( rows )
% metaStruct = obj.rows( rows )
% Returns a structure with the metadata at the specified row for each
% dimension. If the rows are for a single state vector variable, the fields
% of the structure are the different dimensions. If the rows cover multiple
% state vector variables, then the fields of the structure are the
% variables covered by the rows. Each field contains a sub-structure with
% the metadata for the dimensions of the variable. Each sub-structure also
% indicates the specified rows that are in the variable.
%
% varStruct = obj.rows(rows, dims)
% metaStruct = obj.rows(rows, dims)
% meta = obj.rows(rows, dim)
% Only returns metadata for specified dimensions. If the rows are for a
% single state vector variable, and only a single dimension is specified,
% then returns the metadata directly as an array.
%
% varStruct = obj.rows(rows, dim, fullStruct)
% Specify to always return the full structure (in which each field
% corresponds to a particular variable).
%
% varNames = obj.rows(rows, 0)
% Return the name of the state vector variable associated with each row.

% Default and error check for fullStruct
if ~exist('fullStruct','var') || isempty(fullStruct)
    fullStruct = false;
end
dash.assertScalarType(fullStruct, 'fullStruct', 'logical', 'logical');

% Error check the rows
rows = dash.checkIndices(rows, 'rows', obj.varLimit(end), 'the number of elements in the state vector');
if ~isrow(rows)
    rows = rows';
end

% Get the variables associated with the rows
isVar = obj.varLimit(:,1)<=rows & obj.varLimit(:,2)>=rows;
[whichVar, ~] = find(isVar);
v = unique(whichVar);
nVars = numel(v);

% Default dimensions
if ~exist('dims','var') || isempty(dims)
    dims = unique(cat(2, obj.dims{v}));
    
% Only return variable names if using the 0 dimension
elseif isequal(dims, 0)
    meta = obj.variableNames(whichVar);
    return;
    
% Error check user-specified dimensions
else
    allDims = unique(cat(2, obj.dims{:}));
    dash.checkStrsInList(dims, allDims, 'dims', 'a dimension of any variable in the state vector ensemble');
    dims = unique(string(dims));
end
nUserDims = numel(dims);

% Initialize the output structure
if fullStruct || nVars>1
    meta = struct();
end

% For each variable, get the name, variable rows, and dimensions
for k = 1:nVars
    varName = obj.variableNames(v(k));
    currentRows = rows(whichVar==v(k));
    varRows = currentRows - obj.varLimit(v(k),1) + 1;
    varDims = dims(ismember(dims, obj.dims{v(k)}));
    nDims = numel(varDims);
    
    % Get the variable metadata
    if nDims==0
        varMeta = [];
    else
        indices = repmat({varRows}, [1 nDims]);
        varMeta = obj.variable(varName, varDims, 'state', indices, true);
    end 
    
    % Return the full output structure
    if fullStruct || nVars>1
        meta.(varName) = varMeta;
        meta.(varName).rows = currentRows;
        meta.(varName) = orderfields(meta.(varName), ["rows"; varDims(:)]);
        
    % Return a metadata structure for a single variable
    elseif nVars==1 && nUserDims>1
        meta = varMeta;
        meta.stateVectorVariable = varName;
        meta = orderfields(meta, ["stateVectorVariable"; varDims(:)]);
        
    % Return an array directly
    elseif nDims==0
        meta = varMeta;
    else
        meta = varMeta.(varDims(1));
    end
end

end