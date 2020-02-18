function[] = convertToV7_3( filename )
% Converts a matfile to v7.3
%
% convertToV7_3( filename )
% Resaves a mat file as -v7.3

% Check the file exists, get path
checkFile( filename, 'exist', true );
fullfile = which( filename );

% Get the temp file name. Ensure no pre-existing temp files are overwritten
tempfile = fullfile;
while exist( tempfile, 'file' )
    tempfile = [tempfile, '.tmp']; %#ok<AGROW>
end

% Test that the file is actually a matfile.
try
    m = matfile( filename );
catch
    error('File %s may not actually be a .mat file.', filename);
end

% Get data fields, check for naming conflicts
fields = fields( m );
if any( ismember( fields, ["m","tempfile","f","fields","load","fullfile","error"] ) )
    error('File %s contains variables that conflict with named variables in this function. You will need to resave it manually.', filename );
end

% Attempt to load all the data at once. 
fullLoad = true;
try
    load( fullfile, '-mat', fields );
catch
    fullLoad = false;
end
    
% Save all the data at once
if fullLoad
    save( tempFile, '-mat', '-v7.3', fields{:} );

% Save variables iteratively
else
    m = matfile( tempFile );
    for f = 1:numel(fields)
        
        % Try to load each variable in full
        try
            load( fullfile, '-mat', fields{f} );
        catch
            error('Variable %s is too large to load into memory.', fields{f} );
        end
        m.(fields{f}) = fields{f};
    end
end

% Delete the old file and rename
delete( fullfile );
movefile( tempfile, fullfile );


end        
