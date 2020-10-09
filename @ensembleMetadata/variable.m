function[meta] = variable(obj, varName, dims, type, indices)
%% Returns metadata down the state vector or across the ensemble for a
% variable in a state vector ensemble.
%
% metaStruct = obj.lookup(varName)
% Returns the metadata for the non-singleton dimensions of a variable in a
% state vector ensemble. Returns the metadata down the state vector for
% state dimensions and the metadata across the ensemble for ensemble
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
% [...] = obj.lookup(varName, dim, type/returnState, indices)
% [...] = obj.lookup(varName, dims, type/returnState, indexCell)
% Return the metadata for specific elements of a variable.
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
% indices: The elements across the ensemble or along the variable's state
%    vector at which to return metadata for a dimension. Either a set of
%    linear indices, or a logical vector. If a logical vector, must have
%    one element per element of the variable in the state vector when
%    returning metadata down the state vector and one element per ensemble
%    member when returning metadata across the ensemble.
%
% indexCell: A cell vector. Each element must contain the indices for the
%    corresponding dimension listed in dims. If an element is an empty
%    array, returns metadata at all elements down the state vector or
%    across the ensemble, as appropriate.
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

% Defaults and error check for dims. Get dimension indices and type.
if ~exist('dims','var') || isempty(dims)
    dims = obj.dims{v}(obj.stateSize{v}>1 | ~obj.isState{v} | obj.meanSize{v}>1);
end
dims = dash.assertStrList(dims);
nDims = numel(dims);
d = dash.checkStrsInList(dims, obj.dims{v}, 'dims', sprintf('dimension of variable "%s"', varName));

% Default for type. Parse metadata direction.
if ~exist('type','var') || isempty(type)
    type = obj.isState{v}(d);
end
returnState = obj.parseDirection(type, nDims);

% Default and parse indices
if ~exist('indices','var') || isempty(indices)
    indices = cell(1, nDims);
end
[indices, wasCell] = dash.parseInputCell(indices, nDims, 'indexCell');
name = 'indices';
if wasCell
    name = 'indexCell';
end

% Initialize output structure
if nDims > 1
    meta = struct();
end

% Propagate state dimensions over all other state dimensions
if any(returnState)
    subDimension = cell(1, numel(obj.dims{v}));
    [subDimension{:}] = ind2sub( obj.stateSize{v}, (1:obj.nEls(v))' );
    subDimension = cell2mat(subDimension);
end 

% Determine which metadata direction to use for each dimension
for k = 1:nDims
    if returnState(k)
        nEls = obj.nEls(v);
        lengthName = sprintf('the number of elements of variable "%s" in the state vector', varName);
    else
        nEls = obj.nEns;
        lengthName = 'the number of ensemble members';
    end

    % Error check indices. Use all if unspecified
    if isempty(indices{k})
        indices{k} = 1:nEls;
    end
    indices{k} = dash.checkIndices(indices{k}, name, nEls, lengthName);
    
    % Metadata for ensemble and state dimensions. Need to propagate state
    % metadata over all state dimensions.
    if ~returnState(k)
        dimMeta = obj.metadata.(varName).ensemble.(dims(k));
        if ~isempty(dimMeta)
            dimMeta = dimMeta(indices{k},:);
        end
    else
        dimMeta = obj.metadata.(varName).state.(dims(k));
        rows = subDimension(indices{k}, d(k));
        dimMeta = dimMeta(rows,:,:);
    end
    
    % Return as array or structure
    if nDims==1
        meta = dimMeta;
    else
        meta.(dims(k)) = dimMeta;
    end
end

end