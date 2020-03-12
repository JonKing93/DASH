function[] = checkFile( filename, varargin )
% 'extension', ext
% 'exist', tf

if ~isstrflag(filename)
    error('filename must be a string scalar or character row vector.');
end

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
if ~isstrflag( filename )
    error('file name must be a string or character row vector.');
end

% Extension
if ~isempty(ext)
    filename = char(filename);
    nExt = numel(ext);
    if ~strcmp( filename( end-nExt + (1:nExt) ), ext )
        error('filename must end in a %s extension.', ext);
    end
end
    
% Existence
if checkExists && ~exist( filename, 'file' )
    error('The file %s does not exist. It may be misspelled or not on the active path.', filename );
end

end
    