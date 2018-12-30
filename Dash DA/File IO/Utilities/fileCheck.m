function[m] = fileCheck( file )

% Check that the file is a .mat file
if isstring(file)
    file = char(file);
end
if ~strcmpi( file(end-3:end), '.mat' )
    error('File must be a .mat file.');
end

% Get the matfile
m = matfile( file, 'Writable', true );

% Check that it contains the required fields
vars = who(m);

if ~ismember( 'gridData', vars )
    error('The %s file is missing the ''gridData'' variable.', file);
elseif ~ismember( 'dimID', vars )
    error('The %s file is missing the ''dimID'' variable.', file);
elseif ~ismember( 'meta', vars )
    error('The %s file is missing the ''meta'' variable.', file);
end

end