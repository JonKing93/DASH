function[obj] = updateMatfileClass(obj, file, objProps, matFields, objName, extName)
%% Update a class that manages data stored in a .mat file.
%
% obj = dash.updateMatfileClass(obj, file, objProps, matFields, objName, extName)
%
% ----- Inputs -----
%
% obj: An instance of a class that manages data stored in a .mat formatted file.
%
% file: The name of a .mat formatted file. A string.
%
% objProps: The names of the object properties being updated. A string vector.
%
% matFields: The names of the correpsonding fields in the matfile. A string vector.
%
% objName: The type of the object. Used for error messages.
%
% extName: The extension type used by the .mat formatted file.
%
% ----- Outputs -----
%
% obj: The updated object.

% Check the file exists
if ~isfile(file)
    error('The file "%s" no longert exists. It may have been deleted or moved to a new location.', file);
end

% Load the data in the matfile. (Use load instead of indexing to avoid
% calls to "whos", which are expensive)
try
    m = load(file, '-mat', matFields);
catch
    error(['Could not load %s data from "%s". It may not be a %s file. If it ',...
        'a %s file, it may have become corrupted.'], objName, file, extName, extName);
end

% Check each field is in the file
loadedFields = fields(m);
for p = 1:numel(objProps)
    if ~ismember(matFields(p), loadedFields)
        error('File "%s" does not contain the "%s" field.', file, matFields(p));
    end
    
    % Update the property
    obj.(objProps(p)) = m.(matFields(p));
end

end