function[] = fileCheck( file, flag )
%% Checks that a gridded .mat file exists. Returns a writable or read-only 
% matfile object, as required.
%
% m = fileCheck( file )
% Checks that a file is a .grid file on the active path, and that the .grid
% file contains all standard fields.
%
% [~] = fileCheck( file, 'ext' )
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

    % Preallocate names of variables in the .grid file
    a = ncinfo( file );
    nVar = numel(a.Variables);
    varNames = cell( nVar, 1 );
    
    % Get the names of the variables in the grid file
    for v = 1:nVar
        varNames{v} = a.Variables(v).Name;
    end
    
    % Get the names of variables that need to be in the grid file
    checkVar = ["gridData", getDimIDs];
    
    % Check that each necessary variable is in the grid file
    for v = 1:numel(checkVar)
        if ~ismember( checkVar(v), varNames )
            error('The %s file is missing the "%s" variable.', file, checkVar(v) );
        end
    end
end

end