function[] = add( obj, nEns )
%% Adds additional ensemble members to an ensemble object.
%
% obj.add( nEns )
% Adds nEns new members to the ensemble.
% **Note: does not write the new members to file until a call to obj.write
%
% ----- Inputs -----
%
% nEns: The number of ensemble members to add. A scalar, positive integer.

% Error check
if ~isnumeric(nEns) || ~isscalar(nEns) || nEns<=0 || mod(nEns,1)~=0
    error('nEns must be a positive scalar integer.');
end

% Add to the existing ensemble. Extract the design from the new ensemble
newEns = obj.design.buildEnsemble( nEns, obj.random );
obj.design = newEns.design;

% If there is already a .ens file, note there are unsaved changes
if ~isempty(obj.file)
    obj.unsaved = true;
end

end