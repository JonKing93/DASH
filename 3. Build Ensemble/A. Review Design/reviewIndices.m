function[] = reviewIndices( var )
%% Checks that design indices are allowed
%
% var: varDesign
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

for d = 1:numel(var.dimID)
    checkIndices( var, d, var.indices{d} );
    
    if ~var.isState(d)
        checkIndices( var, d, var.seqDex{d}+1 );
        checkIndices( var, d, var.meanDex{d}+1 );
    end
end

end