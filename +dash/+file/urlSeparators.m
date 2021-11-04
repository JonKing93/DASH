function[path] = urlSeparators(path)

path = strsplit(path, '\');
path = strjoin(path, '/');

end