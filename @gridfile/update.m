function[] = update(obj)
%% Updates the current gridfile object to ensure it matches the values
% stored in the associated .grid file.
%
% obj.update;

updateProperties = ["dims","size","isdefined","meta","source","fieldLength",...
                    "maxLength","dimLimit","absolutePath"];
gridFields = ["dims","gridSize","isdefined","metadata","source","fieldLength",...
              "maxLength","dimLimit","absolutePath"];
dash.updateMatfileClass(obj, obj.file, updateProperties, gridFields, 'gridfile', '.grid');

end