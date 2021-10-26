function[type] = contentType(content)

% Get the name
content = char(content);
[~, name] = fileparts(content);

% Folder types
if name(1) == '@'
    type = 'class_folder';
    return;
elseif name(1) == '+'
    type = 'package';
    return;
end

% File types
text = fileread(file);
if strcmp(text(1:8), 'function')
    type = 'function';
elseif strcmp(text(1:8), 'classdef')
    type = 'class';
else
    type = 'other';
end

end

    
