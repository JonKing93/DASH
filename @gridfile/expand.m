function[] = expand(obj, dimension, metadata)
%% gridfile.expand  Increase the length of a dimension in a .grid file
% ----------
%   <strong>obj.expand</strong>(dimension, metadata)
%   Increases the length of a dimension. Appends new metadata values to
%   the existing metadata for the dimension. The number of rows in the new
%   metadata will determine the amount by which the dimension's length is
%   increased.
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
%           (numeric/logical), (char/string/cellstring), and (datetime).
%
% <a href="matlab:dash.doc('gridfile.expand')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:expand";

% Require defined dimension, do not include attributes
dim = dash.assert.strflag(dimension, 'dimension', header);
dimsName = sprintf('dimension in gridfile "%s"', obj.name);
d = dash.assert.strsInList(dim, obj.dims, 'dimension', dimsName, header);

% Get the existing metadata and metadata field sizes
oldMeta = obj.meta.(dim);
[nOldRows, nOldCols] = size(oldMeta);
[nNewRows, nNewCols] = size(metadata);

% Test data types
typeTest = {@isnumeric, @islogical, @ischar, @isstring, @iscellstr, @isdatetime};
nTypes = numel(typeTest);
types = false(nTypes, 2);
for t = 1:nTypes
    types(t,1) = typeTest{t}(oldMeta);
    types(t,2) = typeTest{t}(metadata);
end

% Check that types are compatible and that columns match
if ( any(types(1:2,1)) && ~any(types(1:2,2)) ) || ...  % numeric / logical
   ( any(types(3:5:1)) && ~any(types(3:5,2)) ) || ...  % char / string / cellstring
   (types(6,1) && ~types(6,2))                         % datetime

    typeError(dim, types, obj.name, header);
elseif nNewCols ~= nOldCols
    metadataColumnsError(dim, nNewCols, nOldCols, obj.file, header);
end

% Attempt to concatenate.
try
    metadata = cat(1, oldMeta, metadata);
catch
    couldNotAppendError(dim, obj.file, header);
end

% Ensure the appended metadata has unique rows
[areUnique, repeats] = dash.is.uniqueSet(metadata, true);
if ~areUnique
    duplicateRowsError(dim, repeats, nOldRows, obj.file, header);
end

% Error check / update metadata. Also update sizes
obj.meta = obj.meta.edit(dim, metadata);
obj.size(d) = obj.size(d) + nNewRows;

% Save
obj.save;

end

% Complex error messages
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

% Throw error
id = sprintf('%s:incompatibleDataTypes', header);
error(id, ['Cannot append the new "%s" metadata because its data type (%s) ',...
    'is not compatible with the existing metadata''s type (%s) in gridfile "%s". ',...
    'Compatible types are: %s.'], dim, newType, oldType, file, compatible);
end
function[] = metadataColumnsError(dim, nNew, nOld, gridFile, header)
id = sprintf('%s:wrongNumberOfColumns', header);
error(id, ['The number of columns in the new "%s" metadata (%.f) ',...
    'does not match the number of columns in the existing metadata ',...
    'for the dimension (%.f) in the gridfile.\n\ngridfile: %s'], dim, nNew, nOld, gridFile);
end
function[] = couldNotAppendError(dim, gridFile, header)
id = sprintf('%s:couldNotAppend', header);
error(id, ['Could not append the new "%s" metadata to the existing ',...
    'metadata.\n\ngridfile: %s'], dim, gridFile);
end
function[] = duplicateRowsError(dim, repeats, nOldRows, gridFile, header)

inold = any(repeats<=nOldRows);
id = sprintf('%s:duplicateMetadataRows', header);

% Duplicates are exclusively in new metadata
if ~inold
    repeats = repeats - nOldRows;
    error(id, 'The new "%s" metadata has duplicate rows. (Rows %s)\n\ngridfile: %s',...
        dim, dash.string.list(repeats), gridFile);
    
% New metadata duplicates old metadata
else
    oldRow = find( repeats<=nOldRows, 1);
    oldRow = repeats(oldRow);
    newRow = find(repeats>nOldRows, 1);
    newRow = repeats(newRow) - nOldRows;
    error(id, ['The new "%s" metadata duplicates rows in the existing metadata. ',...
        '(New row %.f, Existing row %.f)\n\ngridfile: %s'], dim, newRow, oldRow, gridFile);
end

end