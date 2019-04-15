function[subSeq] = subSequenceEls( vars )
%% Gets the unique sequence elements for a set of coupled variables.
%
% subSequenceEls( vars )

% Get the ensemble dimensions
ensDex = find( ~vars(1).isState );
nDim = numel(ensDex);

% Initialize the set of subscripted sequence elements. We will need to ensure that the
% sequence elements are always added in the same dimensional order for each
% variable. So we will match the dimIDs to the order in the first variable.
subSeq = [];

% For each variable
for v = 1:numel(vars)
    
    % Initialize a cell of sequence elements for the ensemble dimensions
    % and an array to track the number of sequence elements
    seqEls = cell( size(ensDex) );
    nEls = NaN( size(ensDex) );
    
    % For each ensemble dimension
    for k = 1:nDim
        
        % Get the index of the dimension in the variable
        d = checkVarDim( vars(v), vars(1).dimID( ensDex(k) ) );
        
        % Get the sequence and mean elements
        seqDex = vars(v).seqDex{d};
        meanDex = vars(v).meanDex{d};

        % Add sequence and mean indices to get the actual sequence elements
        seq = seqDex + meanDex';
        seq = seq(:);

        % Add to the set of sequence elements for the variable and record the size
        seqEls{k} = seq;
        nEls(k) = numel(seq);
    end
    
    % We now have the sequence elements for each ensemble dimension for the
    % variable. We want to get subscript indices for N-dimensions, and then
    % get the sequence element associated with each subscript index.
    
    % Get the total number of sequence elements for this variable
    nSeq = prod( nEls );
    
    % Preallocate an array to hold the N-D sequence elements for the variable
    currSeq = NaN( nSeq, nDim );
    
    % Get subscript indices for N-dimensions
    subDex = subdim( nEls, (1:nSeq)' );
    
    % Get the subscripted sequence elements for each dimension for the variable
    for k = 1:nDim
        currSeq(:, k) = seqEls{k}( subDex(:, k) );
    end
    
    % Finally, save the current subscripted sequence elements to the array
    % for all coupled variables
    subSeq = [subSeq; currSeq]; %#ok<AGROW>
end

% Restrict to unique subscripted sequence elements
subSeq = unique( subSeq, 'rows' );
        
end