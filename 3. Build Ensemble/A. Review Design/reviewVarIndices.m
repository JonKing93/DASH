function[] = reviewVarIndices( var )
%% Checks that design indices are allowed
%
% var: varDesign
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% For each dimension
for d = 1:numel(var.dimID)
    checkIndices( var, d, var.indices{d} );
    
    % If an ensemble dimension
    if ~var.isState(d)
        
        % Check the state and sequence indices
        checkIndices( var, d, var.seqDex{d}+1 );
        checkIndices( var, d, var.meanDex{d}+1 );
        
        % Check that ensemble metadata matches the size of the sequence
        if size( var.ensMeta{d},1 ) ~= numel(var.seqDex{d})
            error('The number of rows of ensemble metadata for the %s dimension of variable %s does not match the number of sequence indices.', var.dimID{d}, var.name);
        end
    end
    
end

end