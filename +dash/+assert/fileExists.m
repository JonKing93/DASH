function[path] = fileExists( file )
%% Error checking to see if a file exists. If the file exists, returns the
% absolute path as a string with UNIX style file separators.
%
% dash.checkFileExists( fullname )
% Checks if the file exists.
%
% dash.checkFileExists( filename )
% Checks if a file on the active path matches the file name.
%
% path = dash.checkFileExists(...)
% Returns the full file name (including path and extension) as a string.
%
% ----- Inputs -----
%
% fullname: An full file name including path. A string
%
% file: Just the file name. A string. Must include the file extension.
%
% ----- Outputs -----
%
% path: The full file name including path and extension. A string.

% Check that user didn't provide a folder
if isfolder(file)
    error('%s is a folder instead of a file.', file);
end

% Check if the file exists or has a path string.
exist = isfile(file);
path = which(file);

% Throw error if the file doesn't exist
if isempty(path)
    if ~exist
        error("DASH:missingFile",'Could not find file %s. It may be misspelled or not on the active path.', file);
    end

    % Get the path string if off the active path.
    addpath(fileparts(file));
    path = which(file);
    rmpath(fileparts(file));
end

% Use string internally
path = string(path);

end