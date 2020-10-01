function[obj] = update(obj)
%% Updates an ensemble object to match the associated .ens file.
%
% obj = obj.update;
%
% ----- Outputs -----
%
% obj: The updated ensemble object

% Load the matfile fields
fields = ["hasnan","meta","stateVector"];
s = dash.loadMatfileFields(obj.file, fields, '.ens');

% Fill in the fields
for f = 1:numel(fields)
    obj.(fields(f)) = s.(fields(f));
end

end