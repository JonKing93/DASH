function[matchesFile] = findFileSources(obj, file)
%% Finds data sources that match a file name
%
% matchesFile = obj.findFileSources( file )
% If a full file name (including path), finds sources with the exact file 
% path. If only a file name, finds all sources with that name.
%
% ----- Inputs -----
%
% file: The name of a file. A string. 
%
% ----- Outputs -----
%
% matchesFile: A logical vector indicating which sources have the file name (nSource x 1).

% Determine whether to compare file paths or names
file = char(file);
haspath = ~isempty(fileparts(file));

% Get the file names for each source
sourceFile = obj.collectPrimitives("file");
nSource = numel(sourceFile);

if ~haspath
    for s = 1:nSource
        [~, name, ext] = fileparts(sourceFile(s));
        sourceFile(s) = strcat(name, ext);
    end
end

% Determine which sources match the criteria
matchesFile = strcmp(file, sourceFile);

end