function[cv] = coupledVariables( obj )
%% Get the variable indices of each set of coupled varialbes.

% Couple variables to themselves
nVar = numel(obj.var);
obj.isCoupled( 1:nVar+1:end ) = true;

% Get each set of coupled variables. Once a variable is added to a set,
% remove it from the list of unset variables.
nSets = size( unique( obj.isCoupled, 'rows' ), 1);
cv = cell(nSets,1);
unset = 1:nVar;

for s = 1:nSets
    set = find( obj.isCoupled( unset(1), : ) );
    cv{s} = set;
    unset( set ) = [];
end

end