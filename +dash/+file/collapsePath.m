function[path] = collapsePath(path)

path = strsplit(path, {'/','\'});
path(strcmp(path, '.')) = [];

moveUp = find(strcmp(path, '..'), 1);
while ~isempty(moveUp)
    path([moveUp-1, moveUp]) = [];
    moveUp = find(strcmp(path, '..'), 1);
end

path = strjoin(path, '/');

end