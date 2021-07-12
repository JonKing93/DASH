function[] = update(obj)
%% Updates the current gridfile object to ensure it matches the values
% stored in the associated .grid file.
%
% obj.update;


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