function[] = dispAttributes(obj)
%% gridMetadata.dispAttributes  Display metadata attributes in the console
% ----------
%   <strong>obj.dispAttributes</strong>
%   Prints the metadata attributes to the console
% ----------
%
% <a href="matlab:dash.doc('gridMetadata.dispAttributes')">Documentation Page</a>

% Get the attributes structure
dash.assert.scalarObj(obj, 'DASH:gridMetadata:dispAttributes');
[~, atts] = obj.dimensions;
attributes = obj.(atts);

% Get attributes fields
fields = string(fieldnames(attributes));
nFields = numel(fields);

% Exit if there are no fields
if nFields==0
    return
end

% Get whitespace padding for each field name
widths = strlength(fields);
pad = max(widths) - widths;

% Cycle through fields
for f = 1:numel(fields)
    field = fields{f};
    s = struct(field, attributes.(field));

    % Print each field
    padding = repmat(' ', 1, pad(f));
    fprintf(['    ', padding]);
    disp(s);
    fprintf('\b');
end
fprintf('\n');

end