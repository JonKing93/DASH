function[varLimits, varSize, isState, nMean] = varIndices( obj )
%% Returns the state vector index limits and dimensional size of each variable

% Get the variables
vars = obj.var(:);

% Preallocate
nVar = numel( vars );
nDim = numel( vars(1).dimID );
varSize = NaN( nVar, nDim );
isState = true( nVar, nDim );
nMean = ones( nVar, nDim );

% Get the size of each variable in each dimension. Number of state indices,
% or number of sequence indices (adjusted for means)
for v = 1:nVar
    
    for d = 1:nDim   
        if vars(v).isState(d) && ~vars(v).takeMean(d)  % State dimension, no mean
            varSize(v,d) = numel( vars(v).indices{d} ); 
        elseif vars(v).isState(d)                      % State dimension, with mean
            varSize(v,d) = 1;                           
            nMean(v,d) = numel( vars(v).indices{d} );
        else                % Ensemble dimensions
            varSize(v,d) = numel( vars(v).seqDex{d} );
            isState(v,d) = false;
            if vars(v).takeMean(d) % Ensemble dimension with mean
                nMean(v,d) = numel( vars(v).meanDex{d} );
            end
        end
    end
end

% Record the limits
nEls = prod( varSize, 2 );
lastIndex = cumsum(nEls);
varLimits = [lastIndex-nEls+1, lastIndex];
            
end
