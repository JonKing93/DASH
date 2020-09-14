function[matchesFile] = findFileSources(obj, file)
%% Finds data sources that match a file name
%
% matchesFile = obj.findFileSources( file )
% Finds data sources that match a file name. Does not consider file paths.
%
% ----- Inputs -----
%
% file: The name of a file. A string. 
%
% ----- Outputs -----
%
% matchesFile: A logical vector indicating which sources have the file name (nSource x 1).

% Get the file names for the sources
sourceFile = obj.collectPrimitives("file");
nSource = numel(sourceFile);

% Remove paths
[~, name, ext] = fileparts(char(file));
file = strcat(name, ext);

for s = 1:nSource
    [~, name, ext] = fileparts(sourceFile(s));
    sourceFile(s) = strcat(name, ext);
end

% Determine which sources match
matchesFile = strcmp(file, sourceFile);

end