function[m] = fileCheck( file, flag )
%% Checks that a gridded .mat file exists and is valid. Returns a writable
% or read-only matfile object, as required.
%
% fileCheck( file )
% Checks that a file is a .grid file on the active path, and that the .grid
% file was not corrupted during a write operation or externally.
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
m = [];

% If reading / writing
if strcmp(flag, "use")
    
    % Ensure that the file is on the path
    if ~exist(file, 'file')
        error('The file %s cannot be found. It may be misspelled or not on the active path.', file);
    end
    
    % Get the matfile object
    try
        m = load( file, '-mat', 'valid','dimOrder','gridSize','metadata',...
                  'dimLimit','nSource','sourcePath','sourceFile','sourceVar',...
                  'sourceDims','sourceOrder','sourceSize','unmergedSize',...
                  'merge','unmerge','counter' );
    catch ME
        error('File %s is not a valid .grid file. It may be corrupted or not actually a .grid file.', file );
    end
    
    % Check that the file was not corrupted during a write operation
    if ~isscalar(m.valid) || ~islogical(m.valid) || ~m.valid
        error('The file %s is not valid. It may have failed during a write operation.', file);
    end

end

end