function[] = disp(obj, showAttributes)
%% gridMetadata.disp  Display gridMetadata object in console
% ----------
%   <strong>obj.disp</strong>
%   Displays the contents of a gridMetadata object to the console. Displays
%   a link to the gridMetadata documentation page. If the object is scalar,
%   displays dimensions with metadata. If the metadata has a set dimension 
%   order, displays the dimensions in that order. If the metadata has
%   non-dimensional attributes, notes the existence of attributes and links
%   to the attributes fields. If the object is non-scalar, displays the
%   size of the gridMetadata array.
%
%   <strong>obj.disp</strong>(showAttributes)
%   Indicate whether to display the attributes fields in the console. By
%   default, attributes fields are not displayed. This setting only affects
%   the display of scalar object that have non-dimensional attributes.
% ----------
%   Inputs:
%       showAttributes (scalar logical): True if non-dimensional attributes fields
%           should be displayed in the console. False (default) if
%           non-dimensional attributes should not be displayed
% 
% <a href="matlab:dash.doc('gridMetadata.disp')">Documentation Page</a>

% % Parse attributes option
header = "DASH:gridMetadata:disp";
if ~exist('showAttributes','var') || isempty(showAttributes)
    showAttributes = false;
else
    showAttributes = dash.parse.switches(showAttributes, {["h","hide"],["s","show"]},...
        1, 'showAttributes', 'allowed option', header);
end

% Get the class documentation link
link = '<a href="matlab:dash.doc(''gridMetadata'')">gridMetadata</a>';

% If not scalar, display array size and exit
if ~isscalar(obj)
    info = dash.string.nonscalarObj(obj, link);
    fprintf(info);
    return;
end

% Collect the dimension and attribute names
[~, atts] = obj.dimensions;
if ~isempty(obj.order)
    dims = obj.order;
else
    dims = obj.defined;
end

% Collect the defined dimensions in a structure
empty = true;
display = struct();
for d = 1:numel(dims)
    name = dims(d);
    meta = obj.(name);
    if ~isempty(meta)
        display.(name) = meta;
        empty = false;
    end
end

% Determine if attributes should be displayed
hasAttributes = false;
meta = obj.(atts);
if numel(fieldnames(meta))>0
    hasAttributes = true;
    empty = false;

    % Include attributes in struct if not showing fields
    if ~showAttributes
        display.(atts) = meta;
    end
end

% Display an empty metadata object
if empty
    fprintf('  %s with no metadata.\n\n', link);
    return
end

% Display contents
fprintf('  %s with metadata:\n\n', link);
disp(display);

% Display attributes fields
if hasAttributes && showAttributes
    fprintf('    %s:\n',atts);
    obj.dispAttributes;

% Or link to attributes fields
elseif hasAttributes
    link = sprintf('<a href="matlab:%s.dispAttributes">Show attributes</a>', inputname(1));
    fprintf('  %s\n\n', link);
end

end