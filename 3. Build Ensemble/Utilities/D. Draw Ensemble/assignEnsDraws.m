function[vars] = assignEnsDraws( vars, ensDraws, ensID, undrawn )
%% Sets the ensemble indices that will be used in constructing an ensemble.
%
% coupVars: A set of coupled varDesigns
%
% sampDex: Sampling indices from the ensemble draws
%
% ensID: Name of ensemble dimensions
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Store a reference to undrawn ensemble members in the first coupled
% variable so that the ensemble can be increased in size later.
vars(1).undrawn = undrawn;

% For each variable
for v = 1:numel(vars)
    
    % For each ensemble dimension
    for dim = 1:numel(ensID)
        
        % Get the index of the dimension in the variable
        d = checkVarDim( vars(v), ensID(dim) );
        
        % Save the values for the ensemble index draws
        vars(v).drawDex{d} = ensDraws(:,dim);
    end
end

end