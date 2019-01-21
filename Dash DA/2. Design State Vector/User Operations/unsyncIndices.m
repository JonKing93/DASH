function[design] = unsyncIndices( design, vars, varargin )
%% Unsyncs variable indices.

% Parse the inputs
[state, seq, mean] = parseInputs( varargin, {'state','seq','mean'}, {false, false, false}, {'b','b','b'} );

% If none were specified, unsync everything
if ~state && ~seq && ~mean
    state = true;
    seq = true;
    mean = true;
end

% Get the variable indices
v = checkDesignVar( design, vars );

% Unsync
field = {state, 'syncState', seq, 'syncSeq', mean, 'syncMean'};
for f = 1:2:numel(field)
    if field{f}
        design = markSynced( design, v, field{f+1}, false );
    end
end

end