function[seqArray] = buildSequenceArray( fixed, seqDex )
%% Build an array to subscript into each sequence

% Initialize the array size
arraySize = NaN( 1, sum(~fixed));
k = 1;

% For each dimension that is an ensemble dimension
nDim = numel(fixed);
for d = 1:nDim
    if ~fixed(d)
        % Get the number of elements in each sequence
        arraySize(k) = numel( seqDex{d} );
        k = k + 1;
    end
end

% Get the sequence array
seqArray = reshape( 1:prod(arraySize), arraySize );

end