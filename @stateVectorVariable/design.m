function[obj] = design(obj, dims, type, indices)
%% Designs a dimension of a stateVectorVariable
%
% obj = obj.design(dim, type)
% obj = obj.design(dim, isState)
% Specifies a dimension as a state dimension or ensemble dimension. Uses
% all elements along the dimension as state indices or ensemble reference
% indices, as appropriate.
%
% obj = obj.design(dim, 's'/'state'/true, stateIndices)
% Specify state indices for a dimension.
%
% obj = obj.design(dim, 'e'/'ens'/'ensemble'/false, refIndices)
% Specify reference indices for an ensemble dimension.
%
% obj = obj.design(dims, isState/type, indexCell)
% Specify dimension type and indices for multiple dimensions.
%
% ----- Inputs -----
%
% dim: The name of one of the variable's dimensions. A string.
%
% dims: The names of multiple dimensions. A string vector or cellstring
%    vector. May not repeat dimension names.
%
% type: Options are ("state" or "s") to indicate a state dimension, and
%    ("ensemble" / "ens" / "e") to indicate an ensemble dimension. Use a
%    string scalar to specify the same type for all dimensions listed in
%    dims. Use a string vector to specify different options for the
%    different dimensions listed in dims.
%
% isState: True indicates that a dimension is a state dimension. False
%    indicates an ensemble dimension. Use a scalar logical to use the same
%    type for all dimensions listed in dims. Use a logical vector to
%    specify different options for the different dimensions listed in dims.
%
% stateIndices: The indices of required data along the dimension in the
%    variable's .grid file. Either a vector of linear indices or a logical
%    vector the length of the dimension.
%
% refIndices: The ensemble reference indices. Either a vector of linear
%    indices or a logical vector the length of the dimension.
%
% indexCell: A cell vector. Each element contains the state indices or
%    ensemble reference indices for a dimension listed in dims, as
%    appropriate. Must be in the same order as dims. If an element is an
%    empty array, uses all indices along the dimension.

% Error check, dimension index
[d, dims] = obj.checkDimensions(dims);
nDims = numel(d);

% Parse, error check the dimension type. Save
isState = dash.parseLogicalString(type, nDims, 'isState', 'type', ...
                   ["state","s","ensemble","ens","e"], 2, 'The dimension type');
obj.isState(d) = isState;
               
% Parse indices. Get input name
if ~exist('indices','var') || isempty(indices)
    indices = cell(1, nDims);
end
[indices, wasCell] = dash.parseInputCell(indices, nDims, 'indexCell');
name = 'stateIndices';
if ~wasCell && ~isState
    name = 'ensIndices';
end

% Use all indices if unspecified. Error check
for k = 1:nDims
    if isempty(indices{k})
        indices{k} = (1:obj.gridSize(d(k)))';
    end
    if wasCell
        name = sprintf('Element %.f of indexCell', k);
    end
    lengthName = sprintf('the length of the %s dimension', obj.dims(d(k)));
    indices{k} = dash.checkIndices(indices{k}, name, obj.gridSize(d(k)), lengthName);
    
    % State dimension
    if obj.isState(d(k))
        obj.stateSize(d(k)) = numel(indices{k});
        obj.ensSize(d(k)) = 1;
        obj.indices{d(k)} = indices{k}(:);
        
        % Reset ensemble properties
        obj.seqIndices{d(k)} = [];
        obj.seqMetadata{d(k)} = [];
        
        obj.hasMetadata(d(k)) = false;
        obj.metadata{d(k)} = [];
        obj.convert(d(k)) = false;
        obj.convertFunction{d(k)} = [];
        obj.convertArgs{d(k)} = [];
        
        % Update mean properties
        obj.mean_Indices{d(k)} = [];
        if obj.takeMean(d(k))
            if obj.hasWeights(d(k)) && obj.meanSize(d(k))~=obj.stateSize(d(k))
                weightsNumberError(obj, dims(k), obj.stateSize(d(k)), obj.meanSize(d(k)));
            end
            obj.meanSize(d) = obj.stateSize(d);
            obj.stateSize(d) = 1;
        end
    
    % Ensemble dimension
    else
        obj.indices{d(k)} = indices{k}(:);
        obj.stateSize(d(k)) = 1;
        obj.ensSize(d(k)) = numel(indices{k});

        % Check for a conflict with metadata
        if obj.hasMetadata(d(k)) && size(obj.metadata{d(k)},1)~=obj.ensSize(d(k))
            metadataConflictError(obj, d);
        end
        
        % If converting from state, initialize sequence properties and
        % check for meanIndices conflict
        if isempty(obj.seqIndices{d(k)})
            obj.seqIndices{d(k)} = 0;
            obj.seqMetadata{d(k)} = NaN;
            if obj.takeMean(d(k))
                ensMeanError(obj, dims(d(k)));
            end
        end
    end
end

end       
            
% Long error messages
function[] = weightsNumberError( obj, dim, nIndex, nWeights )
error(['Cannot convert the "%s" dimension of variable "%s" to a state ',...
    'dimension because %s is being used in a weighted mean, and the number ',...
    'of state indices (%.f) does not match the number of mean weights ',...
    '(%.f). Either use %.f state indices or reset the mean options using ',...
    '"stateVector.resetMeans".'], dim, obj.name, dim, nIndex, nWeights, nWeights);
end
function[] = metadataConflictError(obj, d)
oldSize = size(obj.metadata{d}, 1);
newSize = obj.ensSize(d);
error(['The new number of reference indices (%.f) for dimension "%s" of ',...
    'variable "%s" does not match the number of rows in the specified ', ...
    'metadata (%.f). Either use %.f indices or reset the metadata options ',...
    'using "stateVector.resetMetadata".'], newSize, obj.dims(d), obj.name, ...
    oldSize, oldSize);
end
function[] = ensMeanError(obj, dim)
error(['Cannot convert dimension "%s" of variable "%s" to an ensemble ',...
    'dimension because it is being used in a mean and there are no mean ',...
    'indices. You may want to reset the mean options using ',...
    '"stateVector.resetMeans".'], dim, obj.name);
end