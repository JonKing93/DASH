function[obj] = edit(obj, varargin)
%% gridMetadata.edit  Edit the metadata for a gridded dataset
% ----------
%   obj = <strong>obj.edit</strong>(dimensions, metadata)
%   Replace the metadata for the named dimensions with the specified new
%   metadata values. For grid dimensions, the new metadata should be a
%   matrix with a supported data type, and cannot contain NaN or NaT
%   elements. If the gridMetadata object has a set dimension order, and the
%   defined dimensions change, also removes the dimension order from the
%   object.
%
%   You may also include "attributes" in the dimension list to edit the
%   non-dimensional attributes. If doing so, the metadata for the
%   "attributes" entry should be a scalar struct, which can contain any
%   fields and values.
%
%   obj = <strong>obj.edit</strong>(dimension1, metadata1, dimension2, metadata2, .., dimensionN, metadataN)
%   obj = <strong>obj.edit</strong>(..., 'attributes', attributes)
%   Uses a Name,Value syntax to edit the dimensions and/or non-dimensional
%   attributes.
% ----------
%   Inputs:
%       dimensions (string vector [nDimensions]): The names of the dimensions whose
%           metadata should be edited. May also include "attributes" in
%           order to edit the non-dimensional attributes.
%       metadata (cell vector [nDimensions] {metadata matrix | scalar struct}):
%           The new metadata values for each edited dimension. A cell
%           vector with one element per edited dimension. Metadata for
%           dimensions should follow the format specified for the
%           "metadataN" input listed below. The new metadata for
%           non-dimensional attributes should be a scalar struct, which may
%           contain any fields or values.
%       dimensionN (string scalar): The name of a dimension of a gridded dataset.
%           Must be a recognized grid dimension. 
%           (See gridMetadata.dimensions for a list of available dimensions)
%       metadataN (matrix, numeric | logical | char | string | cellstring | datetime): 
%           The metadata for the dimension. Cannot have NaN or NaT elements.
%       attributes (scalar struct): Non-dimensional metadata attributes for
%           a gridded dataset. May contain any fields or values useful
%           for the user.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object.
%
% <a href="matlab:dash.doc('gridMetadata.edit')">Documentation Page</a>

% Error header
header = "DASH:gridMetadata:edit";
dash.assert.scalarObj(obj, header);

% Parse inputs
extraInfo = 'Inputs must be Dimension,Metadata pairs.';
[names, metadata] = dash.parse.nameValueOrCollection(varargin, ...
    'dimensions', 'grouped metadata', extraInfo, header);

% Require recognized, non-duplicate dimension names
[dims, atts] = gridMetadata.dimensions;
valid = [dims; atts];
d = dash.assert.strsInList(names, valid, 'Dimension name', 'recognized dimension', header);
dash.assert.uniqueSet(names, 'Dimension name', header);

% Track whether to reset the dimension order
isdefined = ismember(names, obj.defined);
resetOrder = false;

% Cycle through input dimensions
for k = 1:numel(names)
    index = d(k);
    dim = names(k);
    
    % Check metadata is valid.
    if index < numel(dims)
        try
            metadata{k} = gridMetadata.assertField(metadata{k}, dim, header);
        catch ME
            if ~contains(ME.identifier, 'DASH:gridMetadata:edit')
                rethrow(ME);
            end
            throw(ME);
        end

        % Warn user about row vector metadata
        if isrow(metadata{k}) && ~isscalar(metadata{k})
            metadataRowWarning(dim, header);
        end
        
        % Reset dimension order if defined dimensions change
        empty = isempty(metadata{k});
        if (~isdefined(k) && ~empty) || (isdefined(k) && empty)
            resetOrder = true;
        end
        
    % Check attributes are valid
    else
        dash.assert.scalarType(metadata{k}, 'struct', 'attributes', header);
    end
    
    % Update the dimension
    obj.(dim) = metadata{k};
end

% Optionally reset dimension order
if resetOrder
    obj = obj.setOrder(0);
end

end

function[] = metadataRowWarning(dim, header)
id = sprintf('%s:metadataFieldIsRow', header);
warning(id, ['The %s metadata is a row vector and will be used for ',...
    'a single element along the dimension'], dim);
end