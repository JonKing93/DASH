function[] = edit(obj, dimension, metadata)
%% gridfile.edit  Rewrite .grid file metadata
% ----------
%   <strong>obj.edit</strong>(dimension, metadata)
%   Replace the metadata for the named dimension with new values. The new
%   metadata must have the same number of rows as the previous metadata.
%
%   <strong>obj.edit</strong>('attributes', attributes)
%   Replace the existing metadata attributes with new values.
% ----------
%   Inputs:
%       dimension (string scalar): The name of a dimension in the .grid
%           file.
%       metadata (matrix, numeric | logical | char | string | cellstring | datetime):
%           New metadata for the dimension. The number of rows must match
%           the length of the dimension. Cannot have NaN or NaT elements.
%       attributes (scalar struct): New non-dimensional metadata
%           attributes. May contain any fields or contents.
%
% <a href="matlab:dash.doc('gridfile.edit')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:edit";

% Attributes
if strcmp(dimension, 'attributes')
    [~, atts] = gridMetadata.dimensions;
    obj.meta = obj.meta.edit(atts, metadata);
    
% Require a dimension already in the .grid file
else
    dim = dash.assert.strflag(dimension, 'dimension', header);
    dimsName = sprintf('dimension in gridfile "%s"', obj.name);
    d = dash.assert.strsInList(dim, obj.dims, 'dimension', dimsName, header);
    
    % Require metadata rows to match the old size
    oldSize = obj.size(d);
    newSize = size(metadata, 1);
    if newSize~=oldSize
        id = sprintf('%s:differentNumberOfRows', header);
        error(id, ['The number of rows in the new "%s" metadata (%.f) ',...
            'does not match the size of the dimension (%.f) in gridfile "%s".'],...
            dim, newSize, oldSize, obj.name);
    end
    
    % Require unique metadata rows
    obj.meta = obj.meta.edit(dim, metadata);
    obj.meta.assertUnique(dim, header);
end

% Save changes
obj.save;

end