function[] = renameSource( obj, name, newname )
%% Changes the file name associated with a data source to a new file name. 
% Useful if data files are moved to a new location after being added to a
% .grid file.
%
% obj.renameSource( name )
% Updates the file path of data sources associated with the given file
% name. If name is a full file name (including path), only updates data
% sources matching the full file name. If name is just a file name changes
% all data sources with a matching name regardless of path. Locates a file
% on the active path with the same name (excluding path) and changes data
% source file paths to match.
%
% obj.renameSource( name, newname )
% Finds all data sources whose file name matches name and changes the file
% name to newname.  If newname is a full file name (including path), it is
% used directly as the new file name. If newname is just a file name, finds
% a file with the given name on the active path and uses its full name.
%
% ----- Inputs -----
%
% oldname: The file name currently associated with a data source. A string.
%
% newname: The new name of the file associated with a data source. A string.

% Update the grid object in case the file changed
obj.update;

% Error check and set defaults
dash.assertStrFlag(name, "name");
if ~exist('newname','var') || isempty(newname)
    [~, newname, ext] = fileparts(name);
    newname = strcat(newname, ext);
end
dash.assertStrFlag(newname, "newname");
newname = char( dash.checkFileExists(newname) );

% Find file sources that match the name
match = find( obj.findFileSources(name) );
nSource = numel(match);
if nSource==0
    error('None of the data sources in %s are named %s.', obj.file, name);
end

% Get the source metadata
[type, var, unmergedDims, mergedDims, dataType] = ...
    obj.collectPrimitives(["type", "var", "unmergedDims", "mergedDims","dataType"], match);

% Get variables specific for each source being renamed
for s = 1:nSource
    unmerged = gridfile.commaDelimitedToString(unmergedDims(s));
    merged = gridfile.commaDelimitedToString(mergedDims(s));
    oldfile = obj.collectPrimitives("file", match(s));
    
    % Build a data source to check that the new file is still compatible
    % with the old settings.
    source = dataSource.new(type(s), newfile, var(s), unmerged);
    source = gridfile.convertSourceToPrimitives(source);
    
    % Get the dimension lengths for the original data source.
    dimLength = diff(obj.dimLimit(:,:,match(s)),[],2)' + 1;
    [~, reorder] = ismember( merged, grid.dims );
    dimLength = dimLength(reorder);
    
    % Check that the data in the data in the new file still has the correct
    % dimension lengths and data type.
    if any(source.mergedSize ~= dimLength)
        bad = find(source.mergedSize~=dimLength,1);
        error('The length of the %s dimension in file %s (%.f) does not match the length of the dimension in the original data source %s (%.f)', merged(bad), newfile, source.mergedSize(bad), oldfile, dimLength(bad));
    elseif ~strcmp(dataType(s), source.dataType)
        error('The data type of the %s variable in file %s (%s) does not match the data type for the original data source %s (%s)', var(s), newname, dataType(s), oldfile, source.dataType);
    end
end

% Update the primitive array size and padding for the new file name.
sourceFields = fields(obj.source);
f = strcmp('file', sourceFields);
newLength = numel(newname);

if obj.maxLength(f) < newLength
    obj.maxLength(f) = newLength;
    obj.source.file = gridfile.padPrimitives( obj.source.file, newLength );
else
    newname = gridfile.padPrimitives( newname, obj.maxLength(f) );
end

% Rename the sources. Update the .grid file
obj.source.file(match,:) = newname;
obj.fieldLength(match,f) = newLength;
obj.save;

end