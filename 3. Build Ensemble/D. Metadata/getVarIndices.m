function[varDex, varDim] = getVarIndices( design )
%% Gets indices of each variable in a state vector.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Preallocate state indices for each variable
nVar = numel(design.var);
varDex = cell(nVar,1);

% Preallocate dimension size for each variable
nDim = numel(design.var(1).dimID);
varDim = NaN( nVar, nDim );

% Get an increment to count indices
k = 0;

% For each variable
for v = 1:nVar
    var = design.var(v);
    
    % Get the number of elements along each dimension.
    for d = 1:nDim
        
        % For a state dimension without a mean, the number of state indices
        if var.isState(d) && ~var.takeMean(d)
            varDim(v,d) = numel(var.indices{d});
        
        % For a state dimension with a mean, only a single value
        elseif var.isState(d) && var.takeMean(d)
            varDim(v,d) = 1;
            
        % For an ensemble dimension, the number of sequence indices
        else
            varDim(v,d) = numel( var.seqDex{d} );
        end
    end
    
    % Get the indices
    varDex{v} = k + ( 1 : prod(varDim(v,:)) )';
    k = max(varDex{v});
end

end