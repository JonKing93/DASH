function[meta] = variable(obj, varName, dims, type)
%% Returns metadata down the state vector or across the ensemble for a
% variable in a state vector ensemble.
%
% metaStruct = obj.lookup(varName)
% Returns the metadata for the non-singleton dimensions of a variable in a
% state vector ensemble. Returns the metadata down the state vector for
% state dimensions, and the metadata across the ensemble for ensemble
% dimensions.
%
% metaStruct = obj.lookup(varName, dims)
% Only returns metadata for specified dimensions.
%
% meta = obj.lookup(varName, dim)
% Return the metadata for a single dimension directly as an array.
%
% [...] = obj.lookup(varName, dim/dims, type)
% [...] = obj.lookup(varName, dim/dims, returnState)
% Specify whether to return metadata down the state vector or acrosss the
% ensemble for listed dimensions.
%
% ----- Inputs -----
%
% varName: The name of a variable in the state vector. A string.
%
% dim(s): The name(s) of dimensions for which to return metadata. A string
%    vector, cellstring vector, or character row vector.
%
% type: A string indicating which metadata to return.
%    Down the state vector: "state", "s", "down", "d", "rows", or "r"
%    Across the ensemble: "ensemble", "ens", "e", "across", "a", "columns", "cols", or "c"
%    
%    Use a string scalar to use the same metadata direction for all listed
%    dimensions. Use a string vector to specify different directions for
%    different dimensions listed in dims.
%
% returnState: A logical indicating whether to return metadata down the
%    state vector (true), or across the ensemble (false). Use a scalar
%    logical to use the same metadata direction for all listed dimensions. 
%    Use a logical vector to specify different directions listed in dims.
%
% ----- Outputs -----
%
% meta: The metadata for a single dimension. A matrix. If the metadata is
%    down the state vector, has one row per state vector element. If the
%    metadata is across the ensemble, has one row per ensemble member.
%
% metaStruct: A structure containing the metadata for multiple dimensions.

% Error check variable, get index
varName = dash.assertStrFlag(varName, 'varName');
v = dash.checkStrsInList(varName, obj.variableNames, 'varName', 'variable in the state vector');

% Defaults and error check for dims and type. Parse direction options
if ~exist('dims','var') || isempty(dims)
    dims = obj.dims{v}(obj.stateSize{v}>1 | ~obj.isState{v});
end
dims = dash.assertStrList(dims);
d = dash.checkStrsInList(dims, obj.dims{v}, 'dims', sprintf('dimension of variable "%s"', varName));
if ~exist('type','var') || isempty(type)
    type = obj.isState{v}(d);
end
returnState = obj.parseDirection(type, numel(dims));

% Initialize output structure
nDims = numel(dims);
if nDims > 1
    meta = struct();
end

% Propagate state dimensions over all other state dimensions
if any(obj.isState{v}(d))
    subDimension = cell(1, numel(obj.dims{v}));
    [subDimension{:}] = ind2sub( obj.stateSize{v}, (1:obj.nEls(v))' );
    subDimension = cell2mat(subDimension);
end 

% Preallocate metadata structure. Determine which direction to use
for k = 1:nDims
    type = 'state';
    if ~returnState(k)
        type = 'ensemble';
    end
    
    % Get the metadata for the dimension
    dim = dims(k);
    dimMeta = obj.metadata.(varName).(type).(dim);
    
    % Propagate state vector metadata over all state dimensions
    if returnState(k)
        rows = subDimension(:, d(k));
        dimMeta = dimMeta(rows, :);
    end
    
    % Return as array or structure
    if nDims==1
        meta = dimMeta;
    else
        meta.(dim) = dimMeta;
    end
end

end