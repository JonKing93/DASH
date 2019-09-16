function[] = checkFile( filename, varargin )

% Optional inputs
[ext, checkExists] = parseInputs( varargin, {'extension', 'exist'}, {[], false}, {[],[]} );
if ~isempty(ext)
    if ~isstrflag(ext)
        error('extension must be a string or character row vector.');
    end
    ext = char(ext);
    if ~strcmpi( ext(1), '.' )
        error('ext must begin with a "."');
    end
end
if ~islogical(checkExists) || ~isscalar(checkExists)
    error('exist must be a scalar logical.');
end

% File name
if ~isstrflag( file )
    error('file name must be a string or character row vector.');
end

% Extension
if ~isempty(ext)
    filename = char(filename);
    nExt = numel(ext);
    if ~strcmp( filename( end-nExt : (1:nExt) ), ext )
        error('filename must end in a %s extension.', ext);
    end
end
    
% Existence
if checkExist && ~exist( filename, 'file' )
    error('The file %s does not exist. It may be misspelled or not on the active path.', filename );
end

end
    