function[] = package(title, examplesRoot, excludes)
%% doc.package  Builds the RST files for a package and its contents
% ----------
%   doc.package(title, examplesRoot, excludes)
%   Builds the RST pages for the contents of a package. Optionally excludes
%   specified items from the documentation.
% ----------
%   Inputs:
%       title (string scalar): The full dot indexing title of the package
%       examplesRoot (string scalar): The absolute path to the folder
%           holding the markdown examples pages for the package contents
%       excudes (string vector): The names of items in the package that
%           should be excluded from the documentation.
%
%   Outputs:
%       Write the RST file set for the package

% Contents to exclude from build
if ~exist('excludes','var') || isempty(excludes)
    excludes = "";
end
excludes = [".", "..", "Contents.m", excludes];

% Use chars
title = char(title);
examplesRoot = char(examplesRoot);

% Build contents page
write.packageRST(title);
 
% Move to content subfolder
subfolder = parse.name(title, true);
if ~isfolder(subfolder)
    mkdir(subfolder);
end
home = pwd;
goback = onCleanup( @()cd(home) );  % Return to initial location when function ends
cd(subfolder);

% Find the root of the package
packageInfo = [title, '.Contents'];
codeRoot = which(packageInfo);
codeRoot = fileparts(codeRoot);

% Get the contents of the package. Remove excluded 
contents = dir(codeRoot);
files = string({contents.name});
files(ismember(files, excludes)) = [];
contents = strcat(codeRoot, filesep, files);

% Attempt to document the contents. Report problem content if failed
for c = 1:numel(contents)
    try
        doc.content(title, contents(c), examplesRoot)
    catch ME
        [~, name] = fileparts(contents(c));
        cause = MException('', '%s.%s', title, name);
        ME = addCause(ME, cause);
        rethrow(ME);
    end
end

end