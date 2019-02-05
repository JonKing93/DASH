function[rA, dimID] = regridAnalysis( A, var, ensMeta, design )
%% Regrids a variable from a particular time step for an update analysis.
%
% [rA, dimID] = regridAnalysis( A, var, ensMeta, design )
%
% ----- Inputs -----
%
% A: The mean or variance state vector from a particular time step of an
%   udpate analysis.
%
% var: The name of a variable. Must be a string.
%
% ensMeta: Ensemble metadata
%
% design: A state vector design.
%
% ----- Outputs -----
% rA: A regridded analysis for one variable.
%
% dimID: The dimensional ordering of the regridded variable.

% Get the indices of the variable in the state vector
varDex = varCheck(ensMeta, var);

% Also get the variable in the state vector design
v = checkDesignVar(design, var);
var = design.var(v);

% Preallocate the grid size
nDim = numel(var.dimID);
gridSize = ones(1, nDim);

% Get the number of indices in each dimension
for d = 1:nDim
    
    % State dimensions without a mean
    if var.isState(d) && ~var.takeMean(d)
        gridSize(d) = numel(var.indices{d});
        
    % Ensemble dimensions
    elseif ~var.isState(d)
        gridSize(d) = numel(var.seqDex{d});
    end
end

% Regrid the variable in A
rA = reshape( A(varDex), gridSize );

% Get the dimension ordering
dimID = var.dimID;

end