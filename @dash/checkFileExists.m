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

% File with path
if haspath
    if ~isfile(file)
        error('The file %s does not exist.', file);
    end
    
% File without path
else
    file = which(file);
    if isempty(file)
        error('Could not find file %s. It may be misspelled or not on the active path.', file);
    end
end

file = string(file);

end