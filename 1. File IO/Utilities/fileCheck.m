function[m] = fileCheck( file, readOnly )
%% Checks that a gridded .mat file exists. Returns a writable or read-only 
% matfile object, as required.
%
% m = fileCheck( file )
% Returns a writable matfile object.
%
% m = fileCheck( file, 'readOnly' )
% Returns a read-only matfile object. Provides a much faster load if only
% metadata is needed.
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

% Check that the file is a .grid file
if ~isstrflag(file)
    error('File name must be a string.');
end
file = char(file);
if ~strcmpi( file(end-4:end), '.grid' )
    error('File must be a .grid file.');
end

% Ensure that the file is on the path
if ~exist(file, 'file')
    error('The file %s cannot be found.', file);
end

% Get the matfile
if exist('readOnly', 'var') && strcmpi(readOnly, 'readOnly')
    m = matfile(file);
elseif exist('readOnly', 'var')
    error('Unrecognized input');
else
    m = matfile( file, 'Writable', true );
end

% Check that it contains the required fields
vars = who(m);
if ~ismember( 'gridData', vars )
    error('The %s file is missing the ''gridData'' variable.', file);
elseif ~ismember( 'dimID', vars )
    error('The %s file is missing the ''dimID'' variable.', file);
elseif ~ismember( 'meta', vars )
    error('The %s file is missing the ''meta'' variable.', file);
elseif ~ismember( 'gridSize', vars )
    error('The %s file is missing the ''gridSize'' variable.', file );
end

end