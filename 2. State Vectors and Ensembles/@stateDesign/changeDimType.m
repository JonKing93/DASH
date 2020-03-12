function[obj] = changeDimType( obj, v, d )
% Change a dimension from state to ens or vice versa

% Flip the dimension
obj.var(v).isState(d) = ~obj.var(v).isState(d);

% Get coupled, but exclude self
cv = find( obj.isCoupled(v,:) );
cv = cv( cv ~= v );

% Reset values, notify user
obj = obj.resetChangedDim(cv, d);
obj.notifyChangedType( v, d, cv );

end