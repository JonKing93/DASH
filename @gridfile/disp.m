function[] = disp(obj, showSources)
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
%
%   If the .grid file for a scalar object is no longer valid, reports that
%   the object has a invalid .grid file. Displays the name of the file and
%   nothing else. If an element of a gridfile array has an invalid .grid
%   file, lists the name of the file as usual.
%
%   <strong>disp</strong>(obj, showSources)
%   <strong>obj.disp</strong>(showSources)
%   Indicate whether to display the gridfile data sources in the console.
%   Default is to not display data sources. This setting only affects the
%   display of scalar gridfile objects.
% ----------
%   Inputs:
%       showSources (scalar logical | string scalar): Whether or not to
%           display data sources of scalar gridfile objects.
%           [false|"h"|"hide"]: (default) Does not display data sources
%           [true|"s"|"show"]: Displays data sources.
%
%   Outputs:
%       Prints the contents of a gridfile object or array to the console.
%
% <a href="matlab:dash.doc('gridfile.disp')">Documentation Page</a>

% Parse showSources
header = "DASH:gridfile:disp";
if ~exist('showSources','var') || isempty(showSources)
    showSources = false;
else
    showSources = dash.parse.switches(showSources, {["h","hide"],["s","show"]},...
        1, 'showSources', 'allowed option', header);
end

% Get the class documentation link
link = '<a href="matlab:dash.doc(''gridfile'')">gridfile</a>';

% Display empty, scalar, or array as appropriate
if isscalar(obj)
    displayScalar(obj, link, inputname(1), showSources);
else
    displayArray(obj, link);
end

end

% Utilities
function[] = displayScalar(obj, link, name, showSources)

% Deleted object
if ~obj.isvalid
    fprintf('  deleted %s object\n\n', link);
    return
end

% Link header and list file
fprintf('  %s with properties:\n\n', link);

% Update object. Catch invalid file
try
    obj.update;
catch
    fprintf('    <strong><invalid .grid file></strong>\n    %s\n\n', obj.file);
    return
end

% File and dimensions list
fprintf('          File: %s\n', obj.file);
fprintf('    Dimensions: %s\n', strjoin(obj.dims, ', '));
fprintf('\n');

% Dimension sizes and metadata
fprintf('    Dimension Sizes and Metadata:\n');
obj.dispDimensions;

% Metadata attributes
attributes = obj.attributes;
if ~isempty(attributes)
    fprintf('    Attributes:\n');
    obj.meta.dispAttributes;
end

% Default data adjustments (fill, valid range, transform)
obj.dispAdjustments;

% Data sources
fprintf('    Data Sources: %.f\n', obj.nSource);
if showSources
    obj.dispSources(name);
else
    link = sprintf('<a href="matlab:%s.dispSources">Show data sources</a>', name);
    fprintf('\n  %s\n\n', link);
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