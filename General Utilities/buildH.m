function[H] = buildH( F, siteMeta, stateMeta )
%% This builds the cell of indices required to run each forward model.
%
% H = buildH( F, siteMeta, stateMeta )
%
% ----- Inputs -----
%
% F: An array of PSMs. 
%
% siteMeta: A struct array with metadata on the observation sites. (nObs x 1)
%
% stateMeta: A struct array with metadata on the state variables. (nState x 1)
%
% ----- Outputs -----
%
% H: A cell array. Each element is the indices of the state variables
%      needed to run a particular PSM. {nObs x 1}(nVars x 1)

% Get the number of forward models
nPSM = numel(F);

% Preallocate H
H = cell( nPSM, 1 );

% Have each PSM generate its H indices
for m = 1:nPSM
    H{m} = F(m).getStateIndices( siteMeta(m), stateMeta );
end

end