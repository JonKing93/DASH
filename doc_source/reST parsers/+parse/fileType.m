function[type] = fileType(file)

text = fileread(file);
if strcmp(text(1:8), 'function')
    type = 'function';
elseif strcmp(text(1:8), 'classdef')
    type = 'class';
else
    type = 'other';
end

end