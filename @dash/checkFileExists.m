function[path] = checkFileExists( file )
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

% Check that the file exists and that the user didn't provide a folder
if isfolder(file)
    error('%s is a folder instead of a file.', file);
elseif ~isfile(file)
    error('Could not find file %s. It may be misspelled or not on the active path.', file);
end

% Get the full path for the file
path = which(file);
if isempty(path)
    addpath(fileparts(file));
    path = which(file);
    rmpath(fileparts(file));
end

end