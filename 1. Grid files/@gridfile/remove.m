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
% file: A file name. A string. Must include the file extension.
%
% fullname: A full file name including path. A string. Must include the
%    file extension.
%
% var: The name of the variable in the source file. A string.

% Update the grid object in case the .grid file was changed.
obj.update;

% Default for unset var
if ~exist('var','var') || isempty(var)
    var = [];
end

% Error check
dash.assertStrFlag(file, "file");
if ~isempty(var)
    dash.assertStrFlag(var, "var");
end

% Determine which sources match the file name
remove = obj.findFileSources( file );
if ~any(remove)
    error('None of the data sources in %s are named %s.', obj.file, file);
end

% Optionally find sources that match a variable name
if ~isempty(var)
    sourceVar = obj.collectPrimitives("var");
    remove = remove & strcmp(var, sourceVar);
    
    if ~any(remove)
        error('None of data sources in %s with a file name %s have a variable named %s.', obj.file, file, var);
    end
end

% Remove the sources from .grid variables. Update the primitive array size
obj.dimLimit(:,:,remove) = [];
obj.fieldLength(remove,:) = [];
obj.maxLength = max(obj.fieldLength,[],1);

% Remove the sources from the primitive arrays.
sourceFields = fields(obj.source);
nField = numel(sourceFields);
for f = 1:nField
    name = sourceFields{f};
    obj.source.(name)(remove,:) = [];
    
    % Unpad primitives if the size of the primitive array changed
    unpad = size(obj.source.(name),2) - obj.fieldLength(f);
    obj.source.(name)(:,end-unpad+1:end) = [];
end

% Update the .grid file
obj.save;

end
