function[s] = loadMatfileFields(file, fields, extName)
%% Checks that a file is a .mat formatted file with required fields.
% Returns a structure (not a matfile) with the fields.
%
% s = dash.loadMatfileFields(file, fields, extName)
%
% ----- Inputs -----
%
% file: The name of a .mat formatted file. A string.
%
% fields: The names of the required fields in the matfile. A string vector.
%
% extName: The extension type used by the .mat formatted file. A string
%
% ----- Outputs -----
%
% s: A structure with the loaded fields

% Check the file exists
if ~isfile(file)
    error('The file "%s" no longert exists. It may have been deleted or moved to a new location.', file);
end

% Load the data in the matfile. (Use load instead of indexing to avoid
% calls to "whos", which are expensive)
fields = cellstr(fields);
try
    s = load(file, '-mat', fields{:});
catch
    error(['Could not load data from "%s". It may not be a %s file. If it ',...
        'a %s file, it may have become corrupted.'], objName, file, extName, extName);
end

% Check each field is in the file
loadedFields = fields(s);
for p = 1:numel(objProps)
    if ~ismember(fields{p}, loadedFields)
        error('File "%s" does not contain the "%s" field.', file, fields{p});
    end
end

end