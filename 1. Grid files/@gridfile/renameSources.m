function[] = renameSources( obj, name, newname )
%% Changes the file name associated with data sources to a new name. Useful
% if data files are moved to a new location after being added to a .grid
% file.
%
% obj.renameSources
% Iterates through each data source in a .grid file and checks that the
% data source file still exists. If the source file no longer exists, 
% finds a file with the same name (excluding path) on the active path and
% associates the data source with this file. Checks to make sure the new
% file contains the same data as the old.
%
% obj.renameSources( name )
% Only checks and renames source files in the given list of file names. If
% an element of name is a full file name (including path), only checks
% sources matching the full file name. If an element of name is just a file
% name, changes all data sources with a matching file name regardless of
% the file path.
%
% obj.renameSources( name, newname )
% Changes source file names to specified new names. If an element of 
% newname is a full file name (including path), the element is used
% directly as the new file name. If an element of newname is just a file
% name, finds a file on the active path with a name matching newname and
% associates the data sources with this file. If an element of newname is
% an empty string, uses the same file name (excluding path) as the
% associated element of name.
%
% ----- Inputs -----
%
% name: A list of file names. A string vector or cellstring vector.
%    Elements may be full file names (including path), or just file names.
%    All file names must include the extension.
%
% newname: A list of new file names. A string vector or cellstring vector.
%    Must have one element for each element in name. Elements may be a full
%    file name (including path), just file name, or an empty string. All 
%    file names must include the extension.

% Update the grid object in case the file changed
obj.update
nSource = size(obj.fieldLength,1);

% Defaults and error checking for name
if ~exist('name','var') || isempty(name)
    name = obj.collectPrimitives("file", 1:nSource);
    name(isfile(name)) = [];
end
dash.assertStrList(name, "name");
name = string(name);

% Get the data sources associated with each file name.
nFile = numel(name);
fileSources = false(nSource, nFile);
for f = 1:nFile
    fileSources(:,f) = obj.findFileSources(name(f));
    if all( ~fileSources(:,f) )
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

% Get the full new file names
for f = 1:nFile
    if strcmp(newname(f), "")
        [~, file, ext] = fileparts( char(name(f)) );
        newname(f) = [file, ext];
    end
    newname(f) = which(newname(f));
    
    % Check that each new file exists
    if strcmp(newname(f),"") || ~isfile(newname(f))
        error('File %s cannot be found. Either it is not on the active path, or it does not exist.', newname(f));
    end
end

% Record the length of each new file name
newLength = NaN(nFile, 1);

% Build data sources for each new file
for f = 1:nFile
    s = find(fileSources(:,f));
    nSource = numel(s);
    sources = obj.buildSourcesForFiles( s, repmat(newname(f), [nSource,1]) );
    
    % Check that the new data sources match the recorded values in the
    % .grid file.
    obj.checkSourcesMatchGrid( sources, s );
    newLength(f) = numel(char(newname(f)));
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