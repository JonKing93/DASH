function[] = fileCheck( file, flag )
%% Checks that a gridded .mat file exists. Returns a writable or read-only 
% matfile object, as required.
%
% fileCheck( file )
% Checks that a file is a .grid file on the active path, and that the .grid
% file contains all standard fields.
%
% fileCheck( file, 'ext' )
% Only checks that the file has a .grid extension. Does not search the
% active path for the file.
%
% ----- Inputs -----
%
% file: The name of a .grid file. A string.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the flag
if exist('flag','var')
    if ~strcmpi(flag, "ext")
        error('Unrecognized flag.');
    end
else
    flag = 'use';
end 

% Check that the file has a .grid extension.
if ~isstrflag(file)
    error('File name must be a string.');
end
file = char(file);
if ~strcmpi( file(end-4:end), '.grid' )
    error('File must end in a .grid extension.');
end

% If reading / writing
if strcmp(flag, "use")
    
    % Ensure that the file is on the path
    if ~exist(file, 'file')
        error('The file %s cannot be found. It may be misspelled or not on the active path.', file);
    end
    
    % Get the matfile object
    try
        m = matfile( file );
    catch ME
        error('Could not open file %s. It may be corrupted or not actually a .grid file.', file );
    end
    
    % Check that all the required fields are in the file
    vars = who(m);
    required = ["valid","dimOrder","gridSize","metadata","nSource","source","dimLimit"];
    isvar = ismember( required, vars );
    if any( ~isvar )
        error('The %s field is missing from the .grid file.', required(find(~isvar,1)) );
    end
    
    % Check that the file was not corrupted during a write operation
    if ~m.valid
        error('The file %s is not valid. It may have become corrupted during a write operation.');
    end
end

end