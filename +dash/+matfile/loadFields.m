function[s] = loadFields(file, matFields, extName)
%% Checks that a file is a .mat formatted file with required fields.
% Returns a structure (not a matfile) with the fields.
%
% s = dash.loadMatfileFields(file, matFields, extName)
%
% ----- Inputs -----
%
% file: The name of a .mat formatted file. A string.
%
% matFields: The names of the required fields in the matfile. A string vector.
%
% extName: The extension type used by the .mat formatted file. A string
%
% ----- Outputs -----
%
% s: A structure with the loaded fields

% Check the file exists
if ~isfile(file)
    error('The file "%s" does not exist. It may have been deleted or moved to a new location.', file);
end

% Load the data in the matfile. (Use load instead of indexing to avoid
% calls to "whos", which are expensive)
matFields = cellstr(matFields);
try
    s = load(file, '-mat', matFields{:});
catch
    error(['Could not load data from "%s". It may not be a %s file. If it ',...
        'a %s file, it may have become corrupted.'], file, extName, extName);
end

% Check each field is in the file
loadedFields = fields(s);
infile = ismember(matFields, loadedFields);
if any(~infile)
    bad = find(~infile,1);
    id = 'DASH:matfile:missingField';
    error(id, 'File "%s" does not contain the "%s" field.', file, matFields{bad});
end

end