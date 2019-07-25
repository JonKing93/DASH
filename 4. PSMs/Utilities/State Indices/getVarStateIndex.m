function[H] = getVarStateIndex( ensMeta, var )

% Error checking
% warning('No error checking!!!!');

% Ensure that the variable exists and get its index
v = varCheck( ensMeta, var );

% Get the indices
H = ( ensMeta.varLim(v,1) : ensMeta.varLim(v,2) )';

end