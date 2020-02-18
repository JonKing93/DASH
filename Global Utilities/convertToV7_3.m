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

% Test that the file is actually a matfile and not already v7.3
try
    m = matfile( filename );
catch
    error('File %s may not actually be a .mat file.', filename);
end
if m.Properties.SupportsPartialAccess
    error('File %s is already v7.3', filename);
end

% Get data fields, check for naming conflicts
fieldNames = string( fields( m ) );
fieldNames(1) = [];
if any( ismember( fieldNames, ["m","tempfile","f","fields","load","fullfile","error"] ) )
    error('File %s contains variables that conflict with named variables in this function. You will need to resave it manually.', filename );
end

% Check for matfile naming conflict. Temporarily disable warning message.
id = 'MATLAB:load:variableNotFound';
w = warning('query', id);
warning('off', id);
try
    badProp = load( fullfile, 'Properties' );
    warning(w.state, id);
catch
    warning(w.state, id);
end
if ~isempty(fields(badProp))
    error('File %s contains variables that conflict with named variables in this function. You will need to resave it manually.', filename );
end

% Attempt to load all the data at once. 
fullLoad = true;
try
    load( fullfile, '-mat', fieldNames{:} );
catch
    fullLoad = false;
end
    
% Save all the data at once
if fullLoad
    save( tempfile, '-mat', '-v7.3', fieldNames{:} );

% Save variables iteratively
else
    m = matfile( tempfile );
    for f = 1:numel(fieldNames)
        
        % Try to load each variable in full
        try
            load( fullfile, '-mat', fieldNames{f} );
        catch
            error('Variable %s is too large to load into memory.', fieldNames{f} );
        end
        m.(fieldNames{f}) = fieldNames{f};
    end
end

% Delete the old file and rename
delete( fullfile );
movefile( tempfile, fullfile );

end        
