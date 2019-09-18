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

% Add more draws to the design
obj.design = obj.design.makeDraws( nEns );

% Write them to file
obj.design.write( obj.file, obj.random, obj.writenan );

end