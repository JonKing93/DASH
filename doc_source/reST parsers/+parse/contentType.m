function[type] = contentType(content)
%% parse.contentType  Identifies an item in a folder.
% ----------
%   type = parse.contentType(content)
%   Identifies the indicated file as either a class folder, a package, a
%   function, a classdef file, or other.
% ----------
%   Inputs:
%       content (string scalar): The absolute path to a item in a folder.
%
%   Outputs:
%       type (string scalar): A string identifying the item. Options are
%           "class_folder", "package", "function", "classdef", or "other".

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
text = fileread(content);
if strcmp(text(1:8), 'function')
    type = 'function';
elseif strcmp(text(1:8), 'classdef')
    type = 'class';
else
    type = 'other';
end

end