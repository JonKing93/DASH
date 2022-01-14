function[] = rename(obj, sources, newNames)
%% gridfile.rename  Update paths to data sources catalogued in a gridfile
% ----------
%   <strong>obj.rename</strong>
%   Checks every data source in the .grid file to make sure it still
%   exists. If a data source cannot be found, the method searches the
%   active path for files with the same name and extension. If a file with
%   the same name is found, checks that the new file contains a data matrix
%   with the same size and data type as the recorded data source. If so,
%   stores the new file location for the data source. If a data source
%   cannot be found and these criteria are not met, throws an error
%   reporting the missing data source.
%
%   Note: This method only checks the existence of data sources located on
%   a file system drive. Data sources accessed via an OPENDAP url are not
%   checked.
%
%   <strong>obj.rename</strong>(s)
%   <strong>obj.rename</strong>(sourceNames)
%   Specify which data sources should be checked and renamed. Any specified
%   data sources accessed via an OPENDAP url are not checked.
%
%   <strong>obj.rename</strong>(..., newNames)
%   Specify the new names to use for the data sources. Use this syntax when
%   the file name or extension of a data source file has changed. This
%   syntax also allows data sources accessed via an OPENDAP url to be
%   relocated (either to a different OPENDAP url, or a local data file).
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be checked and/or renamed.
%       sourceNames (string vector): The names of the data sources that
%           should be checked and/or renamed.
%       newNames (string vector [nRename]): The new file paths/names for
%           the specified sources. Should have one element per specified
%           data source.
%
% <a href="matlab:dash.doc('gridfile.rename')">Documentation Page</a>

% Setup
header = "DASH:gridfile:rename";
dash.assert.scalarObj(obj, header);
obj.update;

% Get the data sources that should be checked and/or renamed
if exist('sources','var')
    s = obj.sources_.indices(sources, header);
else
    s = 1:obj.nSource;
end
nSources = numel(s);

% Note whether this is an automatic or user-specified rename
userRename = false;
if exist('newNames','var')
    userRename = true;
end

% Error check user names or apply automatic renaming
if userRename
    newNames = dash.assert.strlist(newNames, 'newNames', header);
    dash.assert.vectorTypeN(newNames, [], nSources, 'newNames', header);
else
    newNames = autoRename(obj, s, header);
end

% Build the new data sources, throw error if any build fails
[dataSources, failed, cause] = obj.buildSources(s, true, newNames);
if failed
    s = s(failed);
    invalidDataSourceError(obj, s, newNames(failed), userRename, cause, header);
end

% Update paths and save
for k = 1:nSources
    tryRelative = obj.sources_.relativePath(s(k));
    obj.sources_ = obj.sources_.savePath(dataSources{k}, tryRelative, s(k));
end
obj.save;

end

% Utility function
function[newNames] = autoRename(obj, s, header)

% Preallocate names
nSources = numel(s);
newNames = strings(1, nSources);

% Get the absolute path to each data source
for k = 1:numel(s)
    sourceName = obj.sources_.absolutePaths(s(k));

    % Only update if the file cannot be found. Do not check opendap URLs
    if dash.is.url(sourceName) || isfile(sourceName)
        newNames(k) = sourceName;
        continue;
    end

    % Search for a matching file on the active path. Throw error if no
    % matches are found
    [~, name, ext] = fileparts(sourceName);
    filename = strcat(name, ext);
    newfile = which(filename);
    
    if isempty(newfile)
        noMatchingFileError(sourceName, s(k), obj.file, header);
    end
    newNames(k) = newfile;
end

end

% Error messages
function[] = noMatchingFileError(sourceName, s, gridFile, header)
id = sprintf('%s:noMatchingFile', header);
error(id, ['Data source %.f cannot be found and there are no matching ',...
    'filenames on the active path.\n\n',...
    'Data source: %s\n',...
    '   gridfile: %s'],...
    s, sourceName, gridFile);
end
function[] = invalidDataSourceError(obj, s, newfile, userRename, cause, header)

% Get the file short name
[~, name, ext] = fileparts(string(newfile));
name = strcat(name, ext);

% Different headers for automatic vs user rename
if userRename
    head = sprintf('New data source file "%s"', name);
else
    head = sprintf(['Cannot find data source %.f. A file with the same name (%s) ',...
        'was located on the active path, but it'], s, name);
end

% Detect if source does not match record or if the data source failed
if strcmp(cause.identifier, 'DASH:gridfile:buildSources:sourceDoesNotMatchRecord')
    problem = sprintf(['does not match the values recorded in the gridfile ',...
        'for data source %.f.'], s);
else
    problem = ' is not a valid data source file.';
end

% Base error
base = MException(header, ['%s %s\n\n',...
        '    New data source: %s\n',...
        'Current data source: %s\n',...
        '           gridfile: %s'],...
        head, problem, newfile, obj.sources(s), obj.file);

% Strip nested causes
if ~isempty(cause.cause)
    cause = MException(cause.identifier, '%s', cause.message);
end

% Add cause information and throw
base = addCause(base, cause);
throwAsCaller(base);

end