function[currSeq] = getCurrSequence( fixed, seqArray, s )
%% Get the index of the current sequence for each dimension

% Preallocate a cell of indices for each dimension
currSeq = ones( numel(fixed), 1 );

% Also create a cell for just the ensemble variables
ensSeq = cell( sum(~fixed), 1 );

% Get the index of the current sequence in each ensemble variable
[ensSeq{:}] = ind2sub( size(seqArray), find(seqArray==s) );

% Fill these values into the cell for all dimensions
currSeq( ~fixed ) = [ensSeq{:}];

end



