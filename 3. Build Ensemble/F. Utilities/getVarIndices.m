function[varDex, varDim] = getVarIndices( vars )
%% Gets indices of each variable in a state vector.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Preallocate state indices for each variable
nVar = numel(vars);
varDex = cell(nVar,1);

% Preallocate the set of variable dimensions
varDim = NaN( nVar, numel(vars(1).dimID) );

% Get an increment to count indices
k = 0;

% For each variable
for v = 1:nVar
    
    % Get the variable size
    varDim(v,:) = getVarSize( vars(v) );
    
    % Get the indices
    varDex{v} = k + ( 1 : prod(varDim(v,:)) )';
    k = max(varDex{v});
end

end