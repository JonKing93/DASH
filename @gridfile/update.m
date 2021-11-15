function[] = update(obj)
%% gridfile.update  Update a gridfile object to match the contents of its .grid file
% ----------
%   <strong>obj.update</strong>
%   Updates the current object to match the content of its .grid file. This
%   ensures that the gridfile object matches the file content, even if the
%   .grid file is modified by a second gridfile object.
% ----------
%
% <a href="matlab:dash.doc('gridfile.update')">Documentation Page</a>

% Header for error IDs
header = "DASH:gridfile:update";

% Get the fields
fields = properties('gridfile');
fields(strcmp(fields, 'file')) = [];

% Load the properties
try
    m = load(obj.file, '-mat', fields{:});
catch
    id = sprintf('%s:couldNotLoad', header);
    error(id, 'Could not load data from:\n    %s\nIt may not be a valid .grid file', obj.file);
end

% Ensure every field is in the file
loadedFields = fieldnames(m);
[loaded, loc] = ismember(fields, loadedFields);
if ~all(loaded)
    bad = find(loc==0,1);
    id = sprintf('%s:missingField', header);
    error(id, 'The file:\n    %s\n is missing the "%s" field. It may not be a valid .grid file.', ...
        obj.file, fields(bad));
end

% Update properties
for f = 1:numel(fields)
    obj.(fields{f}) = m.(fields{f});
end

% Add gridfile path to sources object
obj.sources_.gridfile = obj.file;

end