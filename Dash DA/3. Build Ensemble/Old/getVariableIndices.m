function[varCell, nEls] = getVariableIndices( design )
%% Get the number of elements in the total state vector

% Get a cell to hold the state vector indices for each variable
nVar = numel( design.varD );
varCell = cell( nVar, 1 );
nEls = NaN( nVar, 1 );

% Initialize the indexing
last = 0;

% For each variable in the state vector
for v = 1:nVar
    
    % Get the current variable design scheme
    var = design.varDesign(v);
    nDim = numel( var.dimID );
    
    % Preallocate the number of indices in each dimension
    nIndex = NaN(nDim,1);
    
    % Get the number of indices for each dimension
    for d = 1:nDim
        if var.isState(d) 
            nIndex(d) = numel( var.indices{d} );
        else
            nIndex(d) = numel( var.seqDex{d} );
        end
    end
    
    % Get the total number of indices
    nEls(v) = prod(nIndex);
    
    % Get the indices in the state vector
    varCell{v} = last + (1:nEls(v));
    last = max( varCell{v} );
    
end

end
    