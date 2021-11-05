function[] = save(obj)
%% gridfile.save  Save a gridfile object to a .grid file
% ----------
%   <strong>obj.save</strong>
%   Saves the contents of the current gridfile object to its associated
%   .grid file.
% ----------
%
% <a href="matlab:dash.doc('gridfile.save')">Documentation Page</a>

% Strip path from gridfile sources
obj.sources.gridfile = "";

% Get the save properties
props = string(properties(obj));
props(strcmp(props, "file")) = [];

% Build a struct with each value
s = struct();
for p = 1:numel(props)
    s.(props(p)) = obj.(props(p));
end

% Save to file
save(obj.file,  '-mat', '-struct', 's');

end