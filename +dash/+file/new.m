function[filename] = new(filename, ext, overwrite, header)
%% dash.file.new  Do setup tasks for new files
% ----------
%   filename = dash.file.new(filename, ext, overwrite)
%   Gives the filename a default extension if it does not already have the
%   extension. Throws error if the file exists and overwriting is not
%   enabled. Returns the filename as a string.
%
%   filename = dash.file.new(filename, ext, overwrite, header)
%   Use a custom header for error IDs.
% ----------
%   Inputs:
%       filename (string scalar): The name of a new file
%       ext (string scalar | empty matrix): A default extension for the
%           filename. If an empty matrix, does not apply a default
%           extension.
%       overwrite (scalar logical): Whether existing files can be
%           overwritten (true) or not (false).
%       header (string scalar): Header for thrown error IDs. Default is
%           "DASH:file:new".
%
%   Outputs:
%       filename (string scalar): The absolute path to the new file
%
% <a href="matlab:dash.doc('dash.file.new')">Documentation Page</a>

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:file:new";
end

% Ensure the file has the correct extension
[~, ~, currentExt] = fileparts(filename);
if ~strcmpi(ext, currentExt)
    filename = strcat(filename, ext);
end

% Check for overwrite
if ~overwrite && isfile(filename)
    id = sprintf('%s:fileAlreadyExists', header);
    error(id, 'The file "%s" already exists.', filename);
end

% Return name as string
filename = string(filename);

end