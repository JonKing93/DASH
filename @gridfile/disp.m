function[] = disp(obj)
%% gridfile.disp  Display gridfile object in console
% ----------
%   <strong>obj.disp</strong>
%   Displays the contents of a gridfile object to the console. Prints .grid
%   file name, dimensions, dimension sizes, and the limits of dimensional
%   metadata. Prints metadata attributes if they exist. Prints a summary of
%   data sources.
% ----------
%
% <a href="matlab:dash.doc('gridfile.disp')">Documentation Page</a>

% Get the class documentation link
link = '<a href="matlab:dash.doc(''gridfile'')">gridfile</a>';

if ~obj.isvalid
    fprintf('  deleted %s array\n\n', link);
    return;
end

% If scalar, display details. If array, display gridfile names.
if isscalar(obj)
    displayScalar(obj, link, inputname(1));
else
    displayArray(obj, link);
end

end

% Utilities
function[] = displayArray(obj, link)

% Get dimensions size
info = dash.string.nonscalarObj(obj, link);

% Also get name string for each grid
names = strings(size(obj));
for k = 1:numel(obj)
    names(k) = obj(k).name;
end

% Print info, then display names
fprintf(info);
disp(names);

end
function[] = displayScalar(obj, link, name)

% Link header
fprintf('  %s with properties:\n\n', link);

% File and dimensions list
fprintf('          File: %s\n', obj.file);
fprintf('    Dimensions: %s\n', strjoin(obj.dims, ', '));
fprintf('\n');

% Dimension sizes and metadata
obj.dispDimensions(obj.metadata);

% Metadata attributes
[~, atts] = obj.meta.dimensions;
attributes = obj.meta.(atts);
fields = fieldnames(attributes);
if numel(fields)>0
    fields = string(fields);
    maxLength = max(strlength(fields));
    fprintf('    Attributes:\n\n');
    for f = 1:numel(fields)
        fieldLength = strlength(fields(f));
        pad = repmat(' ', 1, maxLength-fieldLength);
        fprintf('\b    %s', pad);
        atts = struct(fields(f), attributes.(fields(f)));
        disp(atts);
    end
end

% Default data adjustments (fill, valid range, transform)
obj.dispAdjustments(obj.fill, obj.range, obj.transform_, obj.transform_params);

% Data sources
if obj.nSource>0
    fprintf('    Data Sources: %.f\n\n', obj.nSource);
    listLink = sprintf('<a href="matlab:%s.dispSources">Show data sources</a>', name);
    fprintf('  %s\n\n', listLink);
end

end         