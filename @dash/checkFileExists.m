function[] = checkFileExists( file )
%% Error checking to see if a file exists.
%
% dash.checkFileExists( fullname )
% Checks if the file exists.
%
% dash.checkFileExists( filename )
% Checks if a file on the active path matches the file name.
%
% ----- Inputs -----
%
% fullname: An full file name including path.
%
% file: Just a file name

if ~dash.isstrflag(file)
    error('file must be a string scalar or character row vector.');
end

file = char(file);
haspath = ~isempty(fileparts(file));
exist = ~isempty(which(file));

if haspath && ~exist
    error('The file %s does not exist.', file);
elseif ~haspath && ~exist
    error('Could not find file %s. It may be misspelled or not on the active path.', file);
end

end