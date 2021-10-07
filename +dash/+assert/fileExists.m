function[fullname] = fileExists(filename, idHeader, ext)
%% Throws an error if a file does not exist
% Uses a custom error message / id based on the name of the file
% variable. If the file does exist, returns the full path to the file as a
% string.
%
% fullname = dash.assert.fileExists(filename, idHeader)
% Tests the existence of the given file. Searches for files with the same
% absolute path, and files on the active path.
%
% fullname = dash.assert.fileExists(filename, idHeader, ext)
% Specify a default extension. If the file is not initially found, but does
% not have the extension, appends the extension and re-checks file
% existence
%
% ----- Inputs -----
%
% filename: A filename being tested. A string scalar or character row vector
%
% idHeader: Header for an error ID. A string scalar.
%
% ext: A default file extension. A string scalar
%
% ----- Outputs -----
%
% fullname: The full file name (including path and extension). A string.

% Get the file path if the file exists
[path, missing] = getpath(filename);

% If the file is missing, check for a default extension
if missing && exist('ext','var') && ~isempty(ext)
    filename = char(filename);
    ext = char(ext);
    N = numel(ext);
    
    % If the file does not have the extension, append and check existence
    if numel(filename)<N || ~strcmp(filename(end-N+1:end), ext)
        [path, missing] = getpath([filename, ext]);
    end
end

% If the file is missing, throw an error
if missing
    id = sprintf('%s:fileNotFound', idHeader);
    error(id, 'File "%s" could not be found. It may be misspelled or not on the active path', filename);
end

% Convert output to string
if nargout>0
    fullname = string(path);
end

end

%% Checks if a file exists. If so, returns the path
function[path, missing] = getpath(file)

% Check if the file exists or has a path string
found = isfile(file);
path = which(file);
empty = isempty(path);
missing = false;

% If the file does not exist, and has no path, it cannot be found
if empty && ~found
    missing = true;

% If the file exists, but the path is empty, find the path
elseif empty
    subpath = fileparts(file);
    addpath(subpath);
    path = which(file);
    rmpath(subpath);
    
% If the full path is not a file, throw error
elseif ~found && ~isfile(path)
    missing = true;
end

end