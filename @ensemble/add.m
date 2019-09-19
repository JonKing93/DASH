function[] = add( obj, nEns )
%% Adds additional ensemble members to a .ens file
%
% obj.add( nEns )
% Adds a specified number of new members.
%
% ----- Inputs -----
%
% nEns: The number of ensemble members to add. A scalar, positive integer.

% Error check
if ~isnumeric(nEns) || ~isscalar(nEns) || nEns<=0 || mod(nEns,1)~=0
    error('nEns must be a positive scalar integer.');
end

% Add more draws to each set of coupled variables
cv = obj.design.coupledVariables;
for set = 1:numel(cv)
    obj.design = obj.design.makeDraws( cv{set}, nEns, obj.random );
end

% Write to file
obj.design.write( obj.file, obj.random, obj.writenan, false );

% Update the ensemble object.
m = matfile( obj.file );
obj.ensSize = m.ensSize;
obj.design = m.design;
obj.hasnan = m.hasnan;

end