function[obj] = update(obj)
%% Updates an ensemble object to match the associated .ens file.
%
% obj = obj.update;
%
% ----- Outputs -----
%
% obj: The updated ensemble object

fields = ["hasnan","meta","stateVector"];
obj = dash.updateMatfileClass(obj, obj.file, fields, fields, 'ensemble', '.ens');

end