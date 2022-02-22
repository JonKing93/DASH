function[] = disp(obj)
%% gridfile.disp  Display gridfile object in console
% ----------
%   <strong>disp</strong>(obj)
%   <strong>obj.disp</strong>
%   Displays the contents of a gridfile object to the console. Begins
%   display with a link to the gridfile documentation page. If the
%   object is scalar, prints the .grid file name, dimensions, dimension
%   sizes, and (when printable) the limits of dimensional metadata. Prints
%   metadata attributes if they exist. If there are data sources, prints
%   the number of data sources and links to a display of all the data
%   source file names.
%
%   If the object is an array, includes the size of the array in the display.
%   Instead of gridfile details, prints the name of the .grid file for each
%   element in the array. If a gridfile array is empty, prints the size of 
%   the empty array and notes that the array is empty.
%
%   If the object is a scalar, deleted gridfile, reports that the gridfile
%   was deleted. Does not print gridfile details. If a gridfile array
%   contains deleted gridfile objects, notes that the array contains
%   deleted elements. The file name of deleted elements is
%   reported as <missing>.
% ----------
%   Outputs:
%       Prints the contents of a gridfile object or array to the console.
%
% <a href="matlab:dash.doc('gridfile.disp')">Documentation Page</a>

% Get the class documentation link
link = '<a href="matlab:dash.doc(''gridfile'')">gridfile</a>';

% Display empty, scalar, or array as appropriate
if isscalar(obj)
    displayScalar(obj, link, inputname(1));
else
    displayArray(obj, link);
end

end

% Utilities
function[] = displayScalar(obj, link, name)

% Deleted object
if ~obj.isvalid
    fprintf('  deleted %s object\n\n', link);
    return
end

% Link header
fprintf('  %s with properties:\n\n', link);

% File and dimensions list
fprintf('          File: %s\n', obj.file);
fprintf('    Dimensions: %s\n', strjoin(obj.dims, ', '));
fprintf('\n');

% Dimension sizes and metadata
obj.dispDimensions;

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
obj.dispAdjustments;

% Data sources
if obj.nSource>0
    fprintf('    Data Sources: %.f\n\n', obj.nSource);
    listLink = sprintf('<a href="matlab:%s.dispSources">Show data sources</a>', name);
    fprintf('  %s\n\n', listLink);
end

end         
function[] = displayArray(obj, link)

% Get dimensions size
info = dash.string.nonscalarObj(obj, link);
fprintf(info);

% If not empty, print file names for each grid
if ~isempty(obj)
    names = strings(size(obj));
    for k = 1:numel(obj)
        if obj(k).isvalid
            names(k) = obj(k).name;
        else
            names(k) = missing;
        end
    end
    disp(names);
end

end