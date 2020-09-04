function[obj] = resetMetadata(obj, dims)
%% Resets specified metadata and metadata conversion options for a variable.
%
% obj = obj.resetMetadata
% Resets metadata options for all dimensions.
%
% obj = obj.resetMetadata(dims)
% Resets metadata options for specified dimensions.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Default for no dims
if ~exist('dims','var')
    d = 1:numel(obj.dims);
else
    d = obj.checkDimensions(dims);
end

% Update
nDims = numel(d);
obj.hasMetadata(d) = false;
obj.metadata(d) = cell(1, nDims);
obj.convert(d) = false;
obj.convertFunction(d) = cell(1, nDims);
obj.convertArgs(d) = cell(1, nDims);

end