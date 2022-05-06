function[] = dash(root, examplesRoot, include)
%% doc.dash  Builds the documentation RST files for all of DASH
% ----------
%   doc.dash(root, examplesRoot, include)
%   Builds the RST files for sphinx given the root of RST documentation
%   files and the root of the markdown examples files. Converts markdown
%   examples to RST and then compiles the sphinx RST file set.
%   
%   You can control which contents of the toolbox are documented
%   by editing the "include" parameter at the top of the method.
% ----------
%   Inputs:
%       root (string scalar): The absolute file path to the root of the RST
%           files for sphinx.
%       examplesRoot (string scalar): The absolute file path to the root of
%           the markdown examples files.
%       include (string vector): The names of the content in the DASH
%           toolbox that should be documented
%
%   Outputs:
%       Writes the RST file set to the current folder.

% Error check files
assert(isfolder(root), 'root folder not found');
assert(isfolder(examplesRoot), 'examples folder not found');

% Get the contents and ensure that the included content is present
contents = dir(root);
files = string({contents.name});
missing = ~ismember(include, files);
if any(missing)
    missing = find(missing,1);
    error('The "%s" content is missing from the DASH toolbox', include(missing));
end

% Get the absolute paths to the contents
contents = strcat(root, filesep, include);

% Build the RST files for each content item
for c = 1:numel(contents)
    doc.content("", contents(c), examplesRoot);
end

end