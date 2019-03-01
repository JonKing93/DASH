function[coupleSet] = reviewDesign( design )
%% Error checks a state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the number of variables
nVar = numel(design.var);

% For each variable
for v = 1:nVar
    
    % Check that the gridfile matches metadata in varDesign
    checkVarMatchesGrid( design.var(v) );
    
    % Check that the indices are all allowed
    reviewIndices( design.var(v) );
end
    
% Check that coupled toggles are correct and get the sets of coupled
% variables
coupleSet = reviewCoupling( design.isCoupled );

end

