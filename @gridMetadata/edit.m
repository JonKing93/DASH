function[obj] = edit(obj, dim, value)
%% gridMetadata.edit  Edit the metadata for a gridded dataset
% ----------
%   obj = obj.edit(dim, meta)
%   Replace the metadata for the named dimension with the specified value
%
%   obj = obj.edit('attributes', attributes)
%   Replace the non-dimensional attributes with the specified values
% ----------
%   Inputs:
%       dim (string scalar): The name of a gridMetadata dimension. See
%           gridMetadata.dimensions for a list of recognized dimensions.
%       meta (matrix, numeric | logical | char | string | cellstring | datetime):
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
dim = dash.assert.strflag(dim, 'dim', header);
n = dash.assert.strsInList(dim, recognized, 'dim', 'recognized dimension name', header);

% Require valid dimensional metadata. Warn about row vectors
if n < numel(recognized)
    value = gridMetadata.assertField(value, dim, header);
    if isrow(value) && ~isscalar(value)
        id = sprintf('%s:metadataFieldIsRow', header);
        warning(id, ['The %s metadata is a row vector and will be used for ',...
            'a single element along the dimension'], dim);
    end
    
% Require valid non-dimensional attributes.
else
    dash.assert.scalarType(value, 'struct', 'attributes', header);
end

% Update object
obj.(dim) = value;

end