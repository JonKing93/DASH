function[] = update(obj)
%% gridfile.update  Updates a gridfile object to match the content of its .grid file.
% ----------
%   <strong>obj.update</strong>
%   Updates the current object to match the content of its .grid file. This
%   ensure that the gridfile object matches the file content, even if the
%   .grid file is modified by a second gridfile object.
% ----------
%
% <a href="matlab:dash.doc('gridfile.update')">Documentation Page</a>


% Load the fields
fields = ["dims","gridSize","isdefined","metadata","source","fieldLength",...
              "maxLength","dimLimit","absolutePath"];
try
    s = dash.matfile.loadFields(obj.file, fields, '.grid');
catch ME
    if strcmp(ME.identifier, 'DASH:matfile:missingField')
        error(['Could not load data from "%s". It may not be a .grid file. If it ',...
            'a .grid file, it may have become corrupted.'], obj.file);
    end
end

% Update properties
props = ["dims","size","isdefined","meta","source","fieldLength",...
                    "maxLength","dimLimit","absolutePath"];
for p = 1:numel(props)
    obj.(props(p)) = s.(fields(p));
end

end