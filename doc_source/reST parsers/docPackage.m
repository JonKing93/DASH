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
mkdir(subfolder);
home = pwd;
goback = onCleanup( @()cd(home) );  % Return to initial location when function ends
cd(subfolder);

% Get the contents of the package. Remove excluded 
contents = dir(codeRoot);
contents = string( {contents.name} );
contents(ismember(contents, excludes)) = [];

% Get the type of each content
for c = 1:numel(contents)
    type = parse.contentType( name );
    
    % Classes
    if strcmp(type, 'class') || strcmp(type, 'class_folder')
        % ...
        
    % Subpackage
    elseif strcmp(type, 'package')
        subCodeRoot = strcat(codeRoot, filesep, contents(f));
        
        name = char(contents(c));
        [~, name] = fileparts(name);
        subExamplesRoot = strcat(examplesRoot, filesep, name(2:end));
        
        docPackage(subCodeRoot, subExamplesRoot);
        
    % Function
    elseif strcmp(type, 'function')
        [~, name] = fileparts(contents(f));
        codeFile = strcat(codeRoot, filesep, contents(f));
        exampleFile = strcat(examplesRoot, filesep, name, ".md");
    
    % No example files if there are not examples
    if ~isfile(exampleFile)
        exampleFile = [];
    end
    
    % Write the .rst for each function
    write.functionHelp(codeFile, exampleFile);
end

end