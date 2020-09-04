function[obj] = specifyMetadata(obj, dim, metadata)
%% Specify metadata at the ensemble reference indices along a dimension
%
% obj = obj.specifyMetadata(dim, metadata)
%
% ----- Inputs -----
%
% dim: The name of the dimension for which metadata is provided. A string
%
% metadata: Metadata at the reference indices for an ensemble dimension.
%    Metadata may be numeric, logical, char, string, cellstring, or
%    datetime matrix. Must have one row per reference index. Each row must
%    be unique and cannot contain NaN or NaT elements. Cellstring
%    metadata will be converted into the "string" type.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Error check, dimension index. Cannot conflict with metadata conversion
d = obj.checkDimensions(dim, false);
if any(obj.convert(d))
    previousMetadataError(obj, d);
end

% Check the metadata is an allowed gridfile type. Convert cellstrings
gridfile.checkMetadataField(metadata, dim);
if iscellstr(metadata) %#ok<ISCLSTR>
    metadata = string(metadata);
end

% Check the rows match the number of reference indices
if size(metadata,1) ~= obj.ensSize(d)
    error(['The metadata for the "%s" dimension of variable "%s" must have ',...
        'one row per reference index (%.f rows), but it has %.f rows instead.'], ...
        dim, obj.name, obj.ensSize(d), size(metadata,1));
end

% Update
obj.hasMetadata(d) = true;
obj.metadata{d} = metadata;

end

% Error message
function[] = previousMetadataError(obj, d)
bad = d(find(obj.convert(d),1));
error('Cannot specify metadata for the "%s" dimension of variable "%s" ',...
    'because you previously specified a metadata conversion function ',...
    'for this dimension. You may want to reset the metadata options ', ...
    'using "stateVector.resetMetadata".', obj.dims(bad), obj.name);
end