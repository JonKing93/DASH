function[m] = fileCheck( file, flag )
%% Checks that a gridded .mat file exists. Returns a writable or read-only 
% matfile object, as required.
%
% m = fileCheck( file )
% Checks that a file is a .grid file on the active path, and that the .grid
% file contains all standard fields. Returns a writable matfile object for
% the .grid file.
%
% m = fileCheck( file, 'readOnly' )
% Returns a read-only matfile object. Provides a much faster load if only
% metadata is needed.
%
% [~] = fileCheck( file, 'ext' )
% Only checks that the file has a .grid extension. Does not search the
% active path or load a matfile object.
%
% ----- Inputs -----
%
% file: The name of a gridded .mat file. A string.
%
% ----- Outputs -----
%
% m: A matfile object for a gridded .mat file.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the flag
if exist('flag','var')
    if ~ismember(flag, ["ext","readOnly"])
        error('Unrecognized flag.');
    end
else
    flag = 'write';
end 

% Check that the file has a .grid extension.
if ~isstrflag(file)
    error('File name must be a string.');
end
file = char(file);
if ~strcmpi( file(end-4:end), '.grid' )
    error('File must be a .grid file.');
end

% Set a default output for when the flag is "ext"
m = [];

% If returning a matfile object
if ismember(flag, ["write","readOnly"])
    
    % Ensure that the file is on the path
    if ~exist(file, 'file')
        error('The file %s cannot be found.', file);
    end
    
    % Load the appropriate matfile object
    if strcmp(flag, 'write')
        m = matfile(file, 'Writable', true);
    else
        m = matfile(file);
    end

    % Check that it contains the required fields
    fields = who(m);
    if ~ismember( 'gridData', fields )
        error('The %s file is missing the ''gridData'' field.', file);
    elseif ~ismember( 'dimID', fields )
        error('The %s file is missing the ''dimID'' field.', file);
    elseif ~ismember( 'meta', fields )
        error('The %s file is missing the ''meta'' field.', file);
    elseif ~ismember( 'gridSize', fields )
        error('The %s file is missing the ''gridSize'' field.', file );
    end
end

end