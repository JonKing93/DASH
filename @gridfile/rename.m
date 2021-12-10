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
    s = obj.sources_.indices(sources, obj.file, header);
else
    s = 1:obj.nSource;
end

% Control flow is quite different for the no-names and user-names cases.
% Process accordingly.
if exist('newNames','var')
    userRename(obj, s, newNames, header);
else
    pathRename(obj, s, header);
end

% Save
obj.save;

end

% Helper subfunctions
function[] = userRename(obj, s, newNames, header)

% Error check names
newNames = dash.assert.strlist(newNames, 'newNames', header);
dash.assert.vectorTypeN(newNames, [], nSources, 'newNames', header);

% Build the data source for each new name, throw informative error if the 
% build fails.
for k = 1:numel(s)
    try
        dataSource = obj.sources_.build(s(k), newNames(k));
    catch cause
        invalidUserDataSourceError(obj, s, k, newNames(k), cause, header);
    end
    
    % Check the saved data array matches the type and size recorded in the gridfile
    [ismatch, prop, sval, gval] = obj.sources_.ismatch(dataSource, s(k));
    if ~ismatch
        userSourceDoesNotMatchError(k, newNames(k), s, obj, prop, sval, gval, header);
    end
    
    % Update path
    tryRelative = obj.sources_.relativePath(s(k));
    obj.sources_ = obj.sources_.savePath(dataSource, tryRelative, s(k));
end

end
function[] = pathRename(obj, s, header)

% Get the absolute path to each data source
for k = 1:numel(s)
    sourceName = obj.sources_.absolutePaths(s(k));

    % Only update if the file cannot be found. Do not check opendap URLs
    if dash.is.url(sourceName) || isfile(sourceName)
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
    
    % Attempt to build the new data source. Give informative error if the
    % build fails.
    try
        dataSource = obj.sources_.build(s(k), newfile);
    catch cause
        invalidPathDataSourceError(obj, s(k), sourceName, newfile, cause, header);
    end

    % Check the saved data matches the size and type recorded in the gridfile.
    [ismatch, prop, sval, gval] = obj.sources_.ismatch(dataSource, s(k));
    if ~ismatch
        pathSourceDoesNotMatchError(newfile, s, obj, prop, sval, gval, header);
    end
    
    % Update path
    tryRelative = obj.sources_.relativePath(s(k));
    obj.sources_ = obj.sources_.savePath(dataSource, tryRelative, s(k));
end

end

% Error messages
function[] = invalidUserDataSourceError(obj, s, nInput, newName, cause, header)
id = sprintf('%s:invalidUserDataSource', header);
currentPath = obj.sources_.absolutePaths(s);
base = error(id, ['New filename %.f is either not a valid data source, or is not ',...
    'a valid replacement for data source %.f in the gridfile.\n\n',...
    '    New data source: %s\n',...
    'Current data source: %s\n',...
    '           gridfile: %s'],...
    nInput, s, newName, currentPath, obj.file);
base = addCause(base, cause);
throw(base);
end
function[] = userSourceDoesNotMatchError(k, newName, s, obj, prop, sval, gval, header)
id = sprintf('%s:sourceDoesNotMatch', header);
oldpath = obj.sources_.absolutePaths(s);
error(id, ['The %s of the data in new file %.f (%s) does not match the %s ',...
    'of data source %.f (%s) recorded in the gridfile.\n\n',...
    'New Data Source: %s\n',...
    'Old Data Source: %s\n',...
    '       gridfile: %s'],...
    prop, k, sval, prop, s, gval, newName, oldpath, obj.file);
end
function[] = noMatchingFileError(sourceName, s, gridFile, header)
id = sprintf('%s:noMatchingFile', header);
error(id, ['Data source %.f cannot be found and there are no matching ',...
    'filenames on the active path.\n\n',...
    'Data source: %s\n',...
    '   gridfile: %s'],...
    s, sourceName, gridFile);
end
function[] = invalidPathDataSourceError(obj, s, oldfile, newfile, cause, header)
id = sprintf('%s:invalidPathDataSource', header);
base = MException(id, ['Data source %.f cannot be found. A file with the ',...
    'same name was located on the active path, but this new file is either ',...
    '1. not a valid data source, or 2. not a valid replacement for data source ',...
    '%.f in the gridfile.\n\n',...
    'Missing Data source: %s\n',...
    '      Matching File: %s\n',...
    '           gridfile: %s'],...
    s, s, oldfile, newfile, obj.file);
base = addCause(base, cause);
throw(base);
end
function[] = pathSourceDoesNotMatchError(newName, s, obj, prop, sval, gval, header)
id = sprintf('%s:sourceDoesNotMatch', header);
oldpath = obj.sources_.absolutePaths(s);
error(id, ['Data source %.f cannot be found. A file of the same name was ',...
    'located on the active path, but the %s of the new file (%s) does not ',...
    'match the %s of data source %.f (%s) recorded in the gridfile.\n\n',...
    'New Data source: %s\n',...
    'Old Data source: %s\n',...
    '       gridfile: %s'],...
    s, prop, sval, prop, s, gval, newName, oldpath, obj.file);
end