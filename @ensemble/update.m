function[obj] = update(obj, ens)
%% Updates an ensemble object to match the associated .ens file.
%
% obj = obj.update
% Loads data from the .ens file and updates the fields.
%
% obj = obj.update(ens)
% Uses a matfile object for the .ens file to update fields
%
% ----- Outputs -----
%
% obj: The updated ensemble object

% If no matfile object is provided, load data into a structure
fields = ["hasnan","metadata","stateVector"];
if ~exist('ens','var') || isempty(ens)
    ens = dash.loadMatfileFields(obj.file, fields, '.ens');
end

% Fill in the fields
for f = 1:numel(fields)
    name = char(fields(f));
    obj.(name) = ens.(name);
end

end