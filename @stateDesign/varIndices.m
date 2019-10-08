function[varLimits, varSize, isState] = varIndices( obj )
%% Returns the state vector index limits and dimensional size of each variable

% Get the variables
vars = obj.var(:);

% Preallocate
nVar = numel( vars );
nDim = numel( vars(1).dimID );
varSize = NaN( nVar, nDim );
isState = true( nVar, nDim );

% Get the size of each variable in each dimension. Number of state indices,
% or number of sequence indices (adjusted for means)
for v = 1:nVar
    
    for d = 1:nDim   
        if vars(v).isState(d) && ~vars(v).takeMean(d)
            varSize(v,d) = numel( vars(v).indices{d} );     % State dimension
        elseif vars(v).isState(d) 
            varSize(v,d) = 1;                           % State dimension with mean
        else
            varSize(v,d) = numel( vars(v).seqDex{d} );      % Ensemble dimension
            isState(v,d) = false;
        end
    end
end

% Record the limits
nEls = prod( varSize, 2 );
lastIndex = cumsum(nEls);
varLimits = [lastIndex-nEls+1, lastIndex];
            
end
