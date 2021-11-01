function[filename] = new( filename, ext, overwrite )
%% Does setup tasks for a new file. Adds the required extension if missing.
% Gets the full file path. If not overwriting, checks the file does not
% already exist.
%
% filename = dash.setupNewFile( filename, ext, overwrite )
%
% ----- Inputs -----
%
% filename: The input name of the file. A string.
%
% ext: The required file extension. A string.
%
% overwrite: A scalar logical indicating whether to overwrite an existing
%    file.
%
% ----- Outputs -----
%
% filename: The full file path. A string

% Ensure the file has the correct extension
[path, ~, currentExt] = fileparts(filename);
if ~strcmpi(currentExt, ext)
    filename = strcat(filename, ext);
end

% Get the full path if unspecified
if isempty(path)
    filename = fullfile(pwd, filename);
end

% If not allowing overlap, check the file does not already exist
if ~overwrite && isfile(filename)
    error('The file "%s" already exists.', filename);
end

% Return filename as a string
filename = string(filename);

end