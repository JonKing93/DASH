function[] = docContent(packageTitle, content, examplesRoot)

% Get the type of content and title
type = parse.contentType(content);
[~, name] = fileparts(content);
name = char(name);

% Adjust name for class folders and packages
if ismember(type, ["class_folder","package"])
    name = name(2:end);
end

% Get title and examples root/file
title = strcat(packageTitle, '.', name);
examples = strcat(examplesRoot, filesep, name);

% Document each type of content
if strcmp(type, 'function')
    docFunction(title, examples);
elseif strcmp(type, 'package')
    docPackage(title, examples);    
elseif strcmp(type,'class') || strcmp(type, 'class_folder')
    docClass(title, examples);
else
    error('Unrecognized content type');
end

end