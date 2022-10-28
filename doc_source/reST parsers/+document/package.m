function[] = package(title, examplesRoot)
%% document.package  Builds and writes the RST markup for a package and its contents
% ----------
%   document.package(title, examplesRoot)
%   Builds the RST pages for the contents of a package, and also the RST
%   for the help text from the package's Contents.m page. The RST file for 
%   the contents page is written to the current directory. The files for
%   the package contents are written to a subfolder of the current directory
%   that matches the package's short title.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the package
%       examplesRoot (string scalar): The absolute path to the folder that
%           holds the examples markdown for the package's contents
%
%   Outputs:
%       Writes the RST file set for the package

% Build the RST file for the package's Contents page
try
    rst = build.packageRST(title);
    
    % Get the name of the file
    titleParts = split(title, '.');
    name = string(titleParts(end));
    newFile = [pwd, filesep, char(name), '.rst'];
    
    % Write the file
    fid = fopen(newFile, 'w');
    closeFile = onCleanup( @()fclose(fid) );
    rst = replace(rst, '\n', newline);
    fprintf(fid, '%s', rst);
    
    % Create a subfolder for the package contents
    subfolder = strcat(pwd, filesep, name);
    if ~isfolder(subfolder)
        mkdir(subfolder);
    end
    
    % Move to the subfolder, but return the the current location when finished
    home = pwd;
    goback = onCleanup( @()cd(home) );  % Return to initial location when function ends
    cd(subfolder);
    
    % Find the root of the package
    packageInfo = strcat(title, '.Contents');
    codeRoot = which(packageInfo);
    codeRoot = fileparts(codeRoot);
    
    % Get the contents of the package. Remove the ., .., Contents.m, and template.m items
    contents = dir(codeRoot);
    contents = string({contents.name});
    remove = ismember(contents, [".","..","Contents.m","template.m"]);
    contents(remove) = [];
    
    % Get the absolute path to each item in the package
    contentPaths = strcat(codeRoot, filesep, contents);
    
    % Document each item in the package (function, subpackage, class file, or class folder)
    for c = 1:numel(contents)
        documentContent(title, contentPaths(c), examplesRoot);
    end

% Informative errror
catch cause
    if strcmp(cause.identifier, 'rst:parser')
        throw(cause);
    else
        rethrow(cause);
    end
end


end

% Utilities
function[] = documentContent(packageTitle, contentPath, examplesRoot)

% Get the short name of the content item
contentPath = char(contentPath);
[~, name] = fileparts(contentPath);

% Determine the type of content
if startsWith(name, '+')
    type = 'subpackage';
elseif startsWith(name, '@')
    type = 'class-folder';
else
    text = fileread(contentPath);
    if strcmp(text(1:8), 'function')
        type = 'function';
    elseif strcmp(text(1:8), 'classdef')
        type = 'class-file';

    % Anything else if not recognized
    else
        error('rst:parser', ['File\n\t%s\nis not a recognized content type.',...
            'Allowed types are subpackages, functions, class folders, and class files'],...
            contentPath);
    end
end

% Remove special characters from the beginning of folder items.
if ismember(type, ["class-folder","subpackage"])
    name = name(2:end);
end

% Get the title and examples root
title = strcat(packageTitle, ".", name);
if ~strcmp(type, 'function')
    examplesRoot = strcat(examplesRoot, filesep, name);
end

% Document the item
if strcmp(type, 'function')
    document.function_(title, examplesRoot);
elseif strcmp(type, 'subpackage')
    document.package(title, examplesRoot);
else
    document.class(title, examplesRoot);
end

end