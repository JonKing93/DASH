function[] = docPackage(codeRoot, examplesRoot)
%% Builds the .rst pages for a package.
%
% Currently does not support subpackages or subclasses

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

% Get the files in the package. Remove ., .., and contents
files = dir(codeRoot);
files = string( {files.name} );
files(1:2) = [];
files(strcmp(files, "Contents.m")) = [];

% Get the files needed to build the .rst for each function
for f = 1:numel(files)
    [~, name] = fileparts(files(f));
    codeFile = strcat(codeRoot, filesep, files(f));
    exampleFile = strcat(examplesRoot, filesep, name, ".md");
    
    % No example files if there are not examples
    if ~isfile(exampleFile)
        exampleFile = [];
    end
    
    % Write the .rst for each function
    write.functionHelp(codeFile, exampleFile);
end

end