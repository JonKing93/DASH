function[] = docPackage(codeRoot, examplesRoot, excludes)
%% Builds the .rst pages for a package.
%
% Currently does not support subpackages or subclasses

% Default
if ~exist('excludes','var') || isempty(excludes)
    excludes = "";
end

% List of contents to exclude from build
excludes = [".", "..", "Contents.m", excludes];

% Use strings internally
codeRoot = string(codeRoot);
examplesRoot = string(examplesRoot);

% Build the contents .rst page
contents = strcat(codeRoot, filesep, "Contents.m");
subfolder = write.packageHelp(contents);

% Create and move to the subfolder for content .rst pages
if ~isfolder(subfolder)
    mkdir(subfolder);
end
home = pwd;
goback = onCleanup( @()cd(home) );  % Return to initial location when function ends
cd(subfolder);

% Get the contents of the package. Remove excluded 
contents = dir(codeRoot);
files = string({contents.name});
files(ismember(files, excludes)) = [];
contents = strcat(codeRoot, filesep, files);

% Get the type of each content
for c = 1:numel(contents)  
    type = parse.contentType(contents(c));
    [~, name] = fileparts( char(contents(c)) );
    
    % Classes
    if strcmp(type, 'class') || strcmp(type, 'class_folder')
        % ...
        
    % Subpackage
    elseif strcmp(type, 'package')
        subCodeRoot = strcat(codeRoot, filesep, name);
        subExamplesRoot = strcat(examplesRoot, filesep, name(2:end));
        docPackage(subCodeRoot, subExamplesRoot);
        
    % Function
    elseif strcmp(type, 'function')
        codeFile = strcat(codeRoot, filesep, name, ".m");
        exampleFile = strcat(examplesRoot, filesep, name, ".md");    
        if ~isfile(exampleFile)
            exampleFile = [];
        end
        
        % Display problem function if failed
        try
            write.functionHelp(codeFile, exampleFile);
        catch ME
            cause = MException('', '%s', codeFile);
            ME = addCause(ME, cause);
            rethrow(ME);
        end
    end
end

end