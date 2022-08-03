function[] = content(packageTitle, content, examplesRoot)
%% doc.content  Builds the RST documentation files for the contents of a non-class folder
% ----------
%   doc.content(packageTitle, content, examplesRoot)
%   Builds the HTML documentation set for contents of a non-class folder.
%   Places the documentation set in the scope of any containing packages.
% ----------
%   Inputs:
%       packageTitle (string scalar): The title of any containing package.
%       content (string scalar): The absolute path to a content.
%           Should begin with + if a package/subpackage, or @ if a class folder.
%       examplesRoot (string scalar): The root of the markdown examples for
%           the content.
%
%   Outputs:
%       Writes the RST files for the folder.

% Get the type of content and title
type = parse.contentType(content);
[~, name] = fileparts(content);
name = char(name);

% Remove + or @ character from class folders and packages
if ismember(type, ["class_folder","package"])
    name = name(2:end);
end

% Get title and root of the examples files
if strcmp(packageTitle, '')
    title = name;
else
    title = strcat(packageTitle, '.', name);
end
examples = strcat(examplesRoot, filesep, name);

% Document each type of content
if strcmp(type, 'function')
    doc.function_(title, examples);
elseif strcmp(type, 'package')
    doc.package(title, examples);    
elseif strcmp(type,'class') || strcmp(type, 'class_folder')
    doc.class(title, examples);
else
    error('The file "%s" is an unrecognized content type.', content);
end

end