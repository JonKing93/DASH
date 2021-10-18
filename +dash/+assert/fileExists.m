function[abspath] = fileExists(filename, ext, idHeader)
%% dash.assert.fileExists  Throw error if a file does not exist
% ----------
%   abspath = dash.assert.fileExists(filename)  
%   Checks if a file exists. If not, throws an error. If so, returns the 
%   absolute path to the file as a string.
%
%   abspath = dash.assert.fileExists(filename, ext)
%   Also checks for files with the given extension.
%
%   abspath = dash.assert.fileExists(filename, ext, idHeader)
%   Uses a custom header in thrown error IDs.
% ----------
%   Inputs:
%       filename (string scalar): The name of a file
%       ext (string scalar | empty array): Default file extension. Leave
%           unset, or use an empty array to not check extensions.
%       idHeader (string scalar): Header to use in thrown error IDs.
%           Default is "DASH:assert:fileExists"
%
%   Outputs:
%       abspath (string scalar): The absolute path to the file
%
%   Throws:
%       <idHeader>:fileNotFound  when the file cannot be found
%
%   <a href="matlab:dash.doc('dash.assert.fileExists')">Online Documentation</a>

% Default
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:assert:fileExists";
end

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
    abspath = string(path);
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