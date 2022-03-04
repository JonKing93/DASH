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
reset = dash.toggleWarning('off', "MATLAB:load:variableNotFound"); %#ok<NASGU>
try
    m = load(obj.file, '-mat', fields{:});
catch
    id = sprintf('%s:couldNotLoad', header);
    ME = MException(id, 'Could not load data from:\n    %s\n\nIt may not be a valid .grid file', obj.file);
    throwAsCaller(ME);
end

% Ensure every field is in the file
loadedFields = fieldnames(m);
[loaded, loc] = ismember(fields, loadedFields);
if ~all(loaded)
    bad = find(loc==0,1);
    id = sprintf('%s:missingField', header);
    ME = MException(id, 'The file:\n\t%s\nis missing the "%s" field. It may not be a valid .grid file.', ...
        obj.file, fields{bad});
    throwAsCaller(ME);
end

% Update properties
for f = 1:numel(fields)
    obj.(fields{f}) = m.(fields{f});
end

% Add gridfile path to sources object
obj.sources_.gridfile = obj.file;

end