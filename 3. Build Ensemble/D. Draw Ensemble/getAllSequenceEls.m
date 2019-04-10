function[seqEls] = getAllSequenceEls( coupVars, dimID )
%% Gets the array of sequence elements for a set of coupled variables. 
% Returns the sequence elements in a specific dimensional order
%
% coupVars: coupled varDesigns
%
% dimID: The dimensional order of the sequence elements
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Initialize an array of sequence elements
seqEls = [];

% For each coupled variable
for c = 1:numel(coupVars)
    
    % Get the order of ensemble dimensions
    dimOrder = checkVarDim( coupVars(c), dimID);
    
    % Get the sequence elements
    newEls = getVarSeqEls( coupVars(c), dimOrder );
    
    % Add to array
    seqEls = [seqEls; newEls]; %#ok<AGROW>
end

% Restrict to unique sequence elements
seqEls = unique(seqEls, 'rows', 'stable' );

end