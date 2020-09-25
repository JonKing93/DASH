function[V, meta] = regrid(obj, X, varName, dimOrder, d, keepSingletons)
%% Extracts a variable from a state vector array and regrids it.
%
% [V, meta] = obj.regrid(X, varName)
% Extracts and regrids a variable from a state vector array. Returns
% metadata for each grid dimension in the order that the dimensions occur
% in the regridded variable.
%
% [...] = obj.regrid(X, varName, dimOrder)
% Request a specific order of grid dimensions for the regridded variable.
% Any unspecified grid dimensions will occur after the specified
% dimensions.
%
% [...] = obj.regrid(X, varName, dimOrder, d)
% Specify which dimension of the input array corresponds to the state
% vector. By default, uses the first dimension. Note that only the state
% vector dimension is regridded. Other dimensions in the array will not be
% affected.
%
% [...] = obj.regrid(X, varName, dimOrder, d, keepSingletons)
% Specify whether to retain singleton grid dimensions in the gridded
% variable. By default, singleton grid dimensions are removed from the
% regridded variable and its metadata. Note that dimensions listed after
% the "dimOrder" flag will never be removed from the gridded variable and
% associated metadata.
%
% ----- Inputs -----
%
% X: An array with a dimension that corresponds to a state vector.
%
% varName: The name of a variable in the state vector. A string.
%
% dimOrder: A requested dimension order for the regridded variable. A string
%    vector or cellstring vector.
%
% d: The dimension in X that corresponds to the state vector. A scalar,
%    positive integer.
%
% keepSingletons: A scalar logical indicating whether to retain singleton
%    dimensions not listed in order in the regridded variable (true), or 
%    not (false -- default).
%
% ----- Outputs -----
%
% V: The regridded variable. An array
%
% meta: Metadata for the regridded dimensions. A structure.

% Defaults
if ~exist('dimOrder','var') || isempty(dimOrder)
    dimOrder = [];
end
if ~exist('d','var') || isempty(d)
    d = 1;
end
if ~exist('keepSingletons','var') || isempty(keepSingletons)
    keepSingletons = false;
end

% Error check variable, get index
dash.assertStrFlag(varName, 'varName');
v = dash.checkStrsInList(varName, obj.variableNames, 'varName', 'variable in the state vector');

% Get user dimensions and dimension order default
userDims = dimOrder;
dims = obj.dims{v};
nDims = numel(dims);
if isempty(dimOrder)
    dimOrder = dims;
end

% Error check
dimOrder = dash.assertStrList(dimOrder, 'dimOrder');
index = dash.checkStrsInList(dimOrder, dims, 'dimOrder', sprintf('dimension of variable "%s"', varName) );
assert( numel(dimOrder)==numel(unique(dimOrder)), 'dimOrder cannot contain duplicate names' );
assert(isscalar(d), 'd must be a scalar');
dash.assertPositiveIntegers(d, 'd');
dash.assertScalarLogical(keepSingletons, 'single');

% Check the array size matches the ensemble metadata
nState = obj.varLimit(end);
if size(X,d) ~= nState
    error('The number of elements along dimension %.f of X (%.f) does not match the length of the state vector (%.f).', d, size(X,d), nState);
end

% Extract the variable and its metadata
indices = repmat({':'}, [1, ndims(X)]);
indices{d} = obj.varLimit(v,1):obj.varLimit(v,2);
V = X(indices{:});
meta = obj.metadata.(varName).state;

% Get the current size and gridded size
siz = size(V);
gridSize = obj.stateSize{v};

% Remove singleton dimensions
if ~keepSingletons
    remove = find( gridSize==1 & ~ismember(dims, userDims) );
    gridSize(remove) = [];
    meta = rmfield(meta, dims(remove));
    nDims = nDims - numel(remove);
    
    % Update permutation order for removed singletons
    if isempty(userDims)
        index(remove) = [];
    end
    index = index - sum(remove<index(:), 2)';
end
    
% Reshape vector to grid
newSize = [siz(1:d-1), gridSize, siz(d+1:end)];
V = reshape(V, newSize);

% Permute to requested dimension order.
gridIndex = 1:nDims;
gridIndex = [index, gridIndex(~ismember(gridIndex, index))];
order = [1:d-1, d-1+gridIndex, nDims-1+(d+1:numel(siz))];
V = permute(V, order);

% Permute metadata fields
order = order(d:d+nDims-1)-d+1;
meta = orderfields(meta, order);

end