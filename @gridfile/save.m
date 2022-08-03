function[] = save(obj)
%% gridfile.save  Save a gridfile object to a .grid file
% ----------
%   <strong>obj.save</strong>
%   Saves the contents of the current gridfile object to its associated
%   .grid file.
% ----------
%
% <a href="matlab:dash.doc('gridfile.save')">Documentation Page</a>

% Get the save properties
props = string(properties(obj));
props(ismember(props, ["file","sources"])) = [];

% Build a struct with each value
s = struct();
for p = 1:numel(props)
    s.(props(p)) = obj.(props(p));
end

% Save sources with stripped gridfile path
sources_ = obj.sources_;
sources_.gridfile = "";
s.sources_ = sources_;

% Save
save(obj.file,  '-mat', '-struct', 's');

end