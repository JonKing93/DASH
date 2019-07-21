function[varLim, varSize, nEls] = getVarIndices( vars )
%% Gets indices of each variable in a state vector.
%
% varLim: The first and last index of each variable in the state vector.
%
% varSize: The dimensional size of the gridded data placed in the state vector 
%
% nEls: The number of elements in each variable
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Preallocate state index limits for each variable
nVar = numel(vars);
varLim = NaN( nVar, 2 );

% Preallocate the dimensional size of each variable and the number of
% elements for each variable
varSize = NaN( nVar, numel(vars(1).dimID) );
nEls = NaN( nVar, 1 );

% Get an increment to count indices
k = 0;

% For each variable
for v = 1:nVar
    
    % Get the variable size
    varSize(v,:) = getVarSize( vars(v) );
    
    % Get the number of elements for the variable
    nEls(v) = prod( varSize(v,:) );
    
    % Get the index limit
    varLim(v,:) = [k+1, k+nEls(v)];
    
    % Increment the counter
    k = k+nEls(v);
end

end