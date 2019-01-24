function[nState, nSeq] = countVarStateSeq( var )

% Initialize the number of state elements and sequences
nState = 1;
nSeq = 1;

% For each dimension
for d = 1:numel(var.dimID)
    % If a state vector
    if var.isState(d) && ~var.takeMean(d)
        nState = nState .* numel(var.indices{d});
        
    elseif var.isState(d)
        nState = nState .* 1;
        
    % If an ensemble vector
    else
        nSeq = nSeq .* numel(var.seqDex{d});
    end
end

end