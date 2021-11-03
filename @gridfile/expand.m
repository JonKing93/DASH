function[] = expand(obj, dimension, metadata)
%% gridfile.expand  Increase the length of a dimension in a .grid file
% ----------
%   obj.expand(dimension, metadata)
%   Increases the length of a dimension. Appends new metadata values to any
%   the existing metadata for the dimension. The number of rows in the new
%   metadata will determine the amount by which the dimension's length is
%   increased.
%
%   If a dimension does not already exist in a .grid file, this method will
%   add the dimension to the file. Any data sources already in the file
%   will be matched to the first element along the dimension.
% ----------
%   Inputs:
%       dimension (string scalar): The name of the dimension whose length
%           should be increased. May be any recognized dimension name (See
%           gridMetadata.dimensions for a list of recognized dimensions)
%       metadata (matrix, numeric | logical | char | string | cellstring | datetime):
%           The metadata values that should be appended to the dimension.
%           Each row is one new element along the dimension. Cellstring
%           metadata will be converted to string.
%
%           If the dimension already exists in the .grid file,
%           metadata must have one column per column in the existing
%           metadata. The new metadata must also have a data type that can
%           be appended to the existing metadata. Compatible data types are
%           (numeric/logical>, (char/string/cellstring), and (datetime).
%
% <a href="matlab:dash.doc('gridfile.expand')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:expand";

% Require valid dimension, do not include attributes
dim = dash.assert.strflag(dimension, 'dimension', header);
dims = gridMetadata.dimensions;
dash.assert.strsInList(dim, dims, 'dimension', 'recognized dimension name', header);

% Get the size of the new metadata. Check whether the dimension is already
% in the .grid file
siz = size(metadata, 1);
[infile, d] = ismember(dim, obj.dims);

% New dimension
if ~infile
    obj.meta = obj.meta.edit(dim, metadata);
    obj.dims = [obj.dims, dim];
    obj.size = [obj.size, siz];

    newRow = ones(size(obj.dimLimit(1,:,:)));
    obj.dimLimit = cat(1, obj.dimLimit, newRow);
    
% Get metadata for existing dimensions and number of columns
else
    oldMeta = obj.meta.(dim);
    oldCols = size(oldMeta,2);
    newCols = size(metadata,2);
    
    % Test data types
    typeTest = {@isnumeric, @islogical, @ischar, @isstring, @iscellstr, @isdatetime};
    nTypes = numel(typeTest);
    types = false(nTypes, 2);
    for t = 1:nTypes
        types(t,1) = typeTest{t}(oldMeta);
        types(t,2) = typeTest{t}(metadata);
    end
    
    % Check that types are compatible
    if ( any(types(1:2,1)) && ~any(types(1:2,2)) ) || ...  % numeric / logical
       ( any(types(3:5:1)) && ~any(types(3:5,2)) ) || ...  % char / string / cellstring
       (types(6,1) && ~types(6,2))                         % datetime
   
        typeError(dim, types, obj.name, header);
        
    % Check columns match
    elseif newCols ~= oldCols
        id = sprintf('%s:wrongNumberOfColumns', header);
        error(id, ['The number of columns in the new "%s" metadata (%.f) ',...
            'does not match the number of columns in the existing metadata ',...
            'for the dimension (%.f) in gridfile "%s".'], dim, newCols, oldCols, obj.name);
    end
    
    % Attempt to concatenate.
    try
        metadata = cat(1, oldMeta, metadata);
    catch
        id = sprintf('%s:couldNotAppend', header);
        error(id, ['Could not append the new "%s" metadata to the existing ',...
            'metadata in gridfile "%s".'], dim, obj.name);
    end
    
    % Error check / update metadata. Also update sizes
    obj.meta = obj.meta.edit(dim, metadata);
    obj.size(d) = obj.size(d) + siz;
end

% Save changes
obj.save;

end

% Complex error message
function[] = typeError(dim, types, file, header)

% Get the type names
typeNames = ["numeric","logical","char","string","cellstring","datetime"];
oldType = typeNames(types(:,1));
newType = typeNames(types(:,2));

% Get the compatible types
groups = {["numeric", "logical"], ["char","string","cellstring"], "datetime"};
for g = 1:numel(groups)
    if ismember(oldType, groups{g})
        compatible = groups{g};
    end
end
compatible = dash.string.list(compatible);

% Issue error
id = sprintf('%s:incompatibleDataTypes', header);
error(id, ['Cannot append the new "%s" metadata because its data type (%s) ',...
    'is not compatible with the existing metadata''s type (%s) in gridfile "%s". ',...
    'Compatible types are: %s.'], dim, newType, oldType, file, compatible);
end