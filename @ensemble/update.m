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

% Fill in the fields. Convert metadata and stateVector back from primitives
obj.has_nan = ens.hasnan;
meta = ensembleMetadata;
obj.metadata = meta.buildFromPrimitives(ens.metadata);
sv = ens.stateVector;
obj.stateVector = sv.revertFromPrimitives;

end