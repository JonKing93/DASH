function[path] = fileExists( file, ext )
%% Error checking to see if a file exists. If the file exists, returns the
% absolute path as a string with UNIX style file separators.
%
% dash.checkFileExists( fullname )
% Checks if the file exists.
%
% dash.checkFileExists( filename )
% Checks if a file on the active path matches the file name.
%
% dash.checkFileExists(name, ext)
% If the initial filename is not found, also searches for a file with the
% given extension.
%
% path = dash.checkFileExists(...)
% Returns the full file name (including path and extension) as a string.
%
% ----- Inputs -----
%
% fullname: An full file name including path. A string
%
% filename: The file name including extension. A string.
%
% name: A file name, optionally including extension. A string.
%
% ext: A default file extension to check if name is not found. A string.
%
% ----- Outputs -----
%
% path: The full file name including path and extension. A string.

% Check that user didn't provide a folder
if isfolder(file)
    error('%s is a folder instead of a file.', file);
end

% Get the file path if it's not missing
[path, missing] = getpath( file );

% If the file is missing, check for a default extension
if missing && exist('ext','var') && ~isempty(ext)
    file = char(file);
    ext = char(ext);
    N = numel(ext);
    
    % Add the extension to the file name and search for the file path
    if numel(file)<N || ~strcmp(file(end-N+1:end), ext)
        fullname = [file, ext];
        [path, missing] = getpath( fullname );
    end
end

% If the file is missing throw an error
if missing
    error("DASH:missingFile",'Could not find file %s. It may be misspelled or not on the active path.', file);
end

% Use string internally for file paths
path = string(path);

end

%% Returns the path to a file
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
