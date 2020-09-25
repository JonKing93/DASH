function[V, meta] = regrid(obj, X, varName, varargin)
%% Extracts a variable from a state vector array and regrids it.
%
% [V, meta] = obj.regrid(X, varName)
% Extracts and regrids a variable from a state vector array. Returns
% metadata for each grid dimension in the order that the dimensions occur
% in the regridded variable.
%
% [...] = obj.regrid(..., 'dimOrder', order)
% Request a specific order of grid dimensions for the regridded variable.
% Any unspecified grid dimensions will occur after the specified
% dimensions.
%
% [...] = obj.regrid(..., 'dim', d)
% Specify which dimension of the input array corresponds to the state
% vector. By default, uses the first dimension. Note that only the state
% vector dimension is regridded. Other dimensions in the array will not be
% affected.
%
% [...] = obj.regrid(..., 'keepSingletons', single)
% Specify whether to retain singleton grid dimensions in the gridded
% variable. By default, singleton grid dimensions are removed from the
% regridded variable and its metadata. Note that dimensions listed after
% the "dimOrder" flag will never be removed from the gridded variable and
% associated metadata.

% Error check, variable index, parse optional inputs
dash.assertStrFlag(varName, 'varName');
v = dash.checkStrsInList(varName, obj.variableNames, 'varName', 'variable in the state vector');
[dimOrder, d, keepSingletons] = dash.parseInputs(varargin, {'dimOrder','dim','keepSingletons'}, {[],1,false}, 2);
dimOrder = string(dimOrder);

% Get user dimensions and dimension order default
userDims = dimOrder;
dims = obj.dims{v};
if isempty(dimOrder)
    dimOrder = dims;
end

% Error check
order = dash.checkStrsInList(dimOrder, dims, 'dimOrder', sprintf('dimension of variable "%s"', varName) );
assert( numel(dimOrder)==numel(unique(dimOrder)), 'dimOrder cannot contain duplicate names');
dash.assertPositiveIntegers(d, 'd');
assert(isscalar(d), 'd must be a scalar');
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

% Optionally remove singleton dimensions
if ~keepSingletons
    remove = find( gridSize==1 & ~ismember(dims, userDims) );
    gridSize(single) = [];
    meta = rmfield(meta, dims(remove));
    order = order - sum(remove<order(:), 2)';
end
    
% Reshape vector to grid
newSize = [siz(1:d-1), gridSize, siz(d+1:end)];
V = reshape(V, newSize);

% Permute to requested dimension order
[V, order] = dash.permuteDimensions(V, order, true, numel(dims(~remove)));
meta = orderfields(meta, order);

end

