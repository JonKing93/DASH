function[] = content(packageTitle, content, examplesRoot)

% Get the type of content and title
type = parse.contentType(content);
[~, name] = fileparts(content);
name = char(name);

% Adjust name for class folders and packages
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
    error('Unrecognized content type');
end

end