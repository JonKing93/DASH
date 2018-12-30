%% This gets the permutation index for two datasets
function[dimDex] = getPermutation( X, Y, knownID )
%% Gets the dimension permutation ordering.

% Check that the values are all recognized
allVals = [X(:);Y(:)];
for d = 1:numel(allVals)
    if ( ~ischar(allVals{d}) && ~isstring(allVals{d}) ) || ~ismember(allVals{d},knownID)
        error('dimension ID %s is not a recognized ID.', allVals{d});
    end
end

% Get the maximum number of dims
nDim = numel(knownID);

% Create an index to order the permutation
dimDex = NaN( nDim, 1 );

% Get the location of each X in Y
for d = 1:numel(X)
    
    % Get the location of X in Y
    [~, loc] = ismember( X{d}, Y );
    
    % If empty, mark with NaN
    if loc==0
        loc = NaN;
    end
    
    % Prevent repeated dimensions
    if numel(loc)>1 || (~isnan(loc) && ismember(loc, dimDex))
        error('A dimension ID is repeated.');
    end
    
    dimDex(d) = loc;
end

% Fill in singleton dimensions
dims = 1:nDim;
dimDex(isnan(dimDex)) = dims( ~ismember(dims,dimDex) );

end