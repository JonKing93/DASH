function[path, isrelative] = relativePath(toFile, fromFolder)

% Get the folders along each path
to = strsplit(toFile, filesep);
from = strsplit(fromFolder, filesep);

% Find the last common folder
n = min(numel(to), numel(from));
match = strcmp(to(1:n), from(1:n));
branch = find(~match, 1, 'first') - 1;
if isempty(branch)
    branch = n;
end

% If no common folders, use the absolute path
if branch==0
    path = toFile;
    isrelative = false;
    
% Otherwise build relative path
else
    nUp = numel(from) - branch;
    toBranch = repmat({'..'}, [1 nUp]);
    path = fullfile('.', toBranch{:}, to{branch+1:end});
    isrelative = true;
end

end