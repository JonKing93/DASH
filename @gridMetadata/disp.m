function[] = disp(obj)
%% gridMetadata.disp  Display gridMetadata object in console
% ----------
%   obj.disp
%   Displays the contents of a gridMetadata object to the console. Only
%   lists dimensions with metadata. Only references attributes when
%   attributes is not empty. If attributes has contents, creates a link to
%   optionally display the attributes.
% ----------
% 
% <a href="matlab:dash.doc('gridMetadata.disp')">Documentation Page</a>

% Collect the dimension and attribute names
props = string(properties(obj));
dims = props(1:end-1);
atts = props(end);

% Collect the dimensions with metadata in a structure
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

% Also determine if attributes should be displayed
hasAttributes = false;
meta = obj.(atts);
if numel(fieldnames(meta))>0
    hasAttributes = true;
    empty = false;
    display.(atts) = meta;
end

% Get the header link
link = '<a href="matlab:dash.doc(''gridMetadata'')">gridMetadata</a>';

% Display an empty metadata object
if empty
    fprintf('  %s with no metadata.\n\n', link);
    return
end

% Display contents
fprintf('  %s with metadata:\n\n', link);
disp(display);

% Attributes contents link
if hasAttributes
    command = sprintf('matlab:%s.dispAttributes', inputname(1));
    link = sprintf('<a href="%s">attributes</a>', command);
    fprintf('  Show %s\n\n', link);
end

end