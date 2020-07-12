function[] = convertToV7_3( filename )
%% Converts a .mat file to a version 7.3 (v7.3) .mat file.
%
% dash.convertToV7_3( filename )
% Resaves a .mat file as a v7.3 .mat file.
%
% ----- Inputs -----
%
% filename: The name of a file. A string. If a full file name (including
%    path), resaves the matching file. If filename is just a file name,
%    searches the active path for a matching file. Filename must include
%    the file extension.

% Error check
dash.assertStrFlag(filename, 'filename');
filename = dash.checkFileExists(filename);

% Going to resave data into a temp file and then rename it. Get the temp 
% file name. Ensure no pre-existing temp files are overwritten
tempfile = filename;
while isfile(tempfile)
    tempfile = strcat(tempfile, '.tmp');
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

% Check if a field is named properties
id = 'MATLAB:load:variableNotFound';
w = warning('query', id);
warning('off', id);
props = load(filename, 'Properties');

hasprops = false;
if isfield(props, 'Properties')
    hasprops = true;
    Properties = props.Properties;
end
warning(w.state, id);

% Use a try catch block to delete the temp file on error
try
    % If there is a properties field, save it directly to the temp file
    if hasprops
        save(tempfile, '-mat', '-v7.3', 'Properties');
    end
    
    % Get a matfile for the temp file. Disable the Properties warning.
    id = 'MATLAB:MatFile:SourceHasReservedNameConflict';
    w = warning('query', id);
    warning('off', id);
    temp = matfile(tempfile, 'Writable', true);
    warning(w.state, id);
        
    % Iteratively add each variable to the temp file
    fieldNames = string(fields(m));
    nField = numel(fieldNames);
    for f = 1:nField
        if ~strcmp(fieldNames(f), 'Properties')
            name = char(fieldNames(f));
            temp.(name) = m.(name);
        end
    end
    
% If the operation fails, delete the temp file and add to error message
catch
    if isfile(tempfile)
        delete(tempfile);   
    end
    error('Could not convert %s to a v7.3 .mat file. You will need to resave it manually.', filename);
end

% Delete the old file and rename
delete( filename );
movefile( tempfile, filename );

end