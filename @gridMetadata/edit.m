function[obj] = edit(obj, dimension, metadata)
%% gridMetadata.edit  Edit the metadata for a gridded dataset
% ----------
%   obj = obj.edit(dimension, metadata)
%   Replace the metadata for the named dimension with new values.
%
%   obj = obj.edit('attributes', attributes)
%   Replace the non-dimensional attributes with the specified values
% ----------
%   Inputs:
%       dimension (string scalar): The name of a gridMetadata dimension. See
%           gridMetadata.dimensions for a list of recognized dimensions.
%       metadata (matrix, numeric | logical | char | string | cellstring | datetime):
%           Metadata for the dimension. Cannot have NaN or NaT elements.
%           All rows must be unique.
%       attributes (scalar struct): Non-dimensional metadata attributes for
%           a gridded dataset. May contain any fields or contents useful
%           for the user.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object.
%
% <a href="matlab:dash.doc('gridMetadata.edit')">Documentation Page</a>

% Header for error IDs
header = 'DASH:gridMetadata:edit';

% Dimension names and attributes name
[dims, atts] = gridMetadata.dimensions;
recognized = [dims;atts];

% Check that the dimension is recognzied
dimension = dash.assert.strflag(dimension, 'dimension', header);
n = dash.assert.strsInList(dimension, recognized, 'dimension', 'recognized dimension name', header);

% Require valid dimensional metadata. Warn about row vectors
if n < numel(recognized)
    metadata = gridMetadata.assertField(metadata, dimension, header);
    if isrow(metadata) && ~isscalar(metadata)
        id = sprintf('%s:metadataFieldIsRow', header);
        warning(id, ['The %s metadata is a row vector and will be used for ',...
            'a single element along the dimension'], dimension);
    end
    
% Require valid non-dimensional attributes.
else
    dash.assert.scalarType(metadata, 'struct', 'attributes', header);
end

% Update object
obj.(dimension) = metadata;

end