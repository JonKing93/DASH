function[] = renameSources( obj, name, newname, absolutePath )
%% Changes the file name associated with data sources to a new name. Useful
% if data files are moved to a new location after being added to a .grid
% file.
%
% obj.renameSources
% Iterates through each data source in a .grid file and checks that the
% data source file still exists. If the source file no longer exists, 
% finds a file with the same name on the active path and associates the
% data source with this file. Checks to make sure the new file contains the
% same data as the old.
%
% obj.renameSources( name )
% Only checks and renames source files in a given list of file names. Only
% considers file name and extension, ignores file paths.
%
% obj.renameSources( name, newname )
% Changes source file names to specified new names. If an element of 
% newname includes the full file path, the element is used directly as the 
% new file name. If an element is an empty string, uses the original file
% name and updates the path. If an element includes a partial file path or
% just a file name, searches the active path for a matching file.
%
% obj.renameSources( name, newname, absolutePath )
% Specify whether to save new file names as absolute paths or as paths
% relative to the .grid file location. If unspecified, uses whichever style
% each data source used previously.
%
% ----- Inputs -----
%
% name: A list of file names. A string vector or cellstring vector. All 
%    file names must include the extension. File paths are ignored.
%
% newname: A list of new file names. A string vector or cellstring vector.
%    Must have one element for each element in name. Elements may be a full
%    file name (including path), just file name, or an empty string. All 
%    file names must include the extension.
%
% absolutePath: A scalar logical vector. Must have one element for each
%    element of "name". True elements indicate that the path for the file
%    should be saved as an absolute path. If false, saves the path relative
%    to the .grid file.

% Update the grid object in case the file changed
obj.update
nSource = size(obj.fieldLength,1);

% Defaults and error checking for name
if ~exist('name','var') || isempty(name)
    name = obj.collectFullPaths(1:nSource);
    name(isfile(name)) = [];
end
dash.assertStrList(name, "name");
name = string(name);

% Get the data sources associated with each file name.
nFile = numel(name);
fileSources = false(nSource, nFile);
for f = 1:nFile
    fileSources(:,f) = obj.findFileSources(name(f));
    if ~any( fileSources(:,f) )
        error('There are no data sources associated with file name %s in .grid file %s', name(f), obj.file);
    end
end

% Defaults and error checking for newname
if ~exist('newname','var') || isempty(newname)
    newname = strings(nFile,1);
end
dash.assertStrList(newname,"newname")
newname = string(newname);
if numel(newname) ~= numel(name)
    error('newname must have one element for each element in name (%.f), but newname currently has %.f elements.', numel(name), numel(newname));
end

% Default and error checking for relativePath
if ~exist('absolutePath','var') || isempty(absolutePath)
    [row, col] = find(fileSources);
    [~, first] = unique(col);
    path = char(obj.collectPrimitives("file", row(first)));
    absolutePath = path(:,1)~='.';
elseif ~isvector(absolutePath) || ~islogical(absolutePath) || numel(absolutePath)~=numel(name)
    error('absolutePath must be a logical vector');
elseif numel(absolutePath) ~= numel(name)
    error('absolutePath must have one element for each element in name (%.f), but absolutePath currently has %.f elements.', numel(name), numel(absolutePath));
end

% Get the full new file paths and check the files exist
for f = 1:nFile
    if strcmp(newname(f), "")
        [~, file, ext] = fileparts( char(name(f)) );
        newname(f) = [file, ext];
    end
    newname(f) = dash.checkFileExists(newname(f));
end

% Preallocate the length of each new file path
newLength = NaN(nFile, 1);

% Build data sources for each new file
for f = 1:nFile
    s = find(fileSources(:,f));
    nSource = numel(s);
    sources = obj.buildSourcesForFiles( s, repmat(newname(f), [nSource,1]) );
    
    % Check that the new data sources match the recorded values in the
    % .grid file.
    obj.checkSourcesMatchGrid( sources, s );
    
    % Implement the desired filepath style. Record the new field length
    newname(f) = obj.sourceFilepath(newname(f), absolutePath(f));
    newLength(f) = numel( char(newname(f)) );
end

% Convert the new file names to primitives. Update primitive array size
newname = char(newname);
newMax = size(newname, 2);
f = strcmp('file', fields(obj.source));

if obj.maxLength(f) < newMax
    obj.maxLength(f) = newMax;
    obj.source.file = gridfile.padPrimitives(obj.source.file, newMax);
else
    newname = gridfile.padPrimitives(newname, obj.maxLength(f));
end

% Rename the sources. Save to .grid file
[~, k] = ismember('file', fields(obj.source));
for f = 1:nFile
    s = find(fileSources(:,f));
    obj.source.file(s,:) = newname(f,:);
    obj.fieldLength(s,k) = newLength(f);
end
obj.save;

end