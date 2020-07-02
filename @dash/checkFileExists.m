function[file] = checkFileExists( file )
%% Error checking to see if a file exists.
%
% dash.checkFileExists( fullname )
% Checks if the file exists.
%
% dash.checkFileExists( filename )
% Checks if a file on the active path matches the file name.
%
% file = dash.checkFileExists(...)
% Returns the full file name as a string.
%
% ----- Inputs -----
%
% fullname: An full file name including path.
%
% file: Just a file name

file = char(file);
haspath = ~isempty(fileparts(file));
exist = ~isempty(which(file));

if haspath && ~exist
    error('The file %s does not exist.', file);
elseif ~haspath && ~exist
    error('Could not find file %s. It may be misspelled or not on the active path.', file);
end

file = string(which(file));

end