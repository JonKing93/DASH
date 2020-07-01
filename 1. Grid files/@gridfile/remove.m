function[] = remove(obj, file, var)
%% Removes a data source from a .grid file.
%
% obj.remove( file )
% Finds all data sources with the specified file name and removes them from
% the grid file.
%
% obj.remove( fullname )
% Finds all data sources with the full file name (including path) and
% removes them from the .grid file.
%
% obj.remove( ..., var )
% Only removes data sources that have both the specified file and variable
% name.
%
% ----- Inputs -----
%
% file: A file name. A string.
%
% fullname: A full file name including path. A string.
%
% var: The name of the variable in the source file. A string.

% Update the grid object in case the .grid file was changed.
obj.update;

% Defaults for unset variables.
if ~exist('var','var') || isempty(var)
    var = [];
end

% Error check
if ~dash.isstrflag(file)
    error('file must be a string scalar or character row vector.');
elseif ~isempty(var) && ~dash.isstrflag(var)
    error('var must be a string scalar or character row vector.');
end

% Determine whether to compare file paths and variable names
file = string(file);
haspath = ~isempty(fileparts(file));
hasvar = ~isempty(var);

% Track which sources match the removal criteria
nSource = numel(obj.source);
matchesFile = false(nSource, 1);
matchesVar = true(nSource, 1);

% Compare the user inputs to the values for each source.
for s = 1:nSource
    [~, name] = fileparts(obj.source(s).file);
    if haspath && strcmp(file, obj.source(s).file)
        matchesFile(s) = true;
    elseif ~haspath && strcmp(file, name)
        matchesFile(s) = true;
    end
    
    if hasvar && matchesFile(s) && ~strcmp(var, obj.source(s).var)
        matchesVar(s) = false;
    end
end

% Check that there are actually sources to remove
if all(~matchesFile)
    error('None of the data sources in %s are named %s.', obj.file, file);
elseif all(~matchesVar)
    error('None of data sources in %s with a file name %s have a variable named %s.', obj.file, file, var);
end

% Remove the sources. Update the .grid file
remove = matchesFile & matchesVar;
obj.source(remove) = [];
obj.dimLimit(:,:,remove) = [];
obj.save;

end
