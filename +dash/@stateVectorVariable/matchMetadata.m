function[obj] = matchMetadata(obj, d, metadata, grid)
%% dash.stateVectorVariable.matchMetadata  Order reference indices so that ensemble metadata matches a ordering set
% ----------
%   obj = <strong>obj.matchMetadata</strong>(d, metadata, grid)
%   Compares the variable's metadata along the indexed dimension to an
%   ordering set of metadata. Removes reference indices with metadata not
%   in the ordering set. Reorders the remaining reference indices to match
%   the order of the ordering set.
%
%   When this method finishes, the reference indices along the dimension
%   point to metadata that exactly matches the ordering set.
%
%   **Note**: This method can only be called after the variable has been
%   finalized.
% ----------
%   Inputs:
%       d (scalar dimension index): The index of an ensemble dimension
%       metadata (matrix): The ordering set of metadata. Reference indices
%           will be updated so that metadata along the dimension exactly
%           matches this set.
%       grid (scalar gridfile object): The gridfile object for the variable
%
%   Outputs:
%       obj (scalar dash.stateVectorVariable object): The variable with
%           updated reference indices and metadata
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.matchMetadata')">Documentation Page</a>

% Get the variable's metadata. Sort the intersect
varMetadata = obj.getMetadata(d, grid);
[~, keep] = intersect(varMetadata, metadata, 'rows', 'stable');

% Update the reference indices and size
obj.indices{d} = obj.indices{d}(keep);
obj.ensSize(d) = numel(obj.indices{d});

% Update alternate metadata if it exists
if obj.metadataType(d)==1
    obj.metadata_{d} = obj.metadata_{d}(keep,:);
end

end