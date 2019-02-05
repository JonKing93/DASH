function[nState, varDex] = getStateVarDex( design )
%% Gets indices of each variable in a state vector. Also returns the total
% number of state elements
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Record the number of state elements for each variable
nVar = numel(design.var);
nState = ones( nVar,1 );

% Also the indices of each variable
varDex = cell(nVar,1);

% Get an increment to count indices
k = 0;

% For each variable
for v = 1:nVar
    var = design.var(v);
    
    % Get the number of dimensions
    nDim = numel(var.dimID);
    
    % For each dimension
    for d = 1:nDim
        
        % If a state dimension and not a mean, mutliply by the number of state elts
        if var.isState(d) && ~var.takeMean(d)
            nState(v) = nState(v) .* numel(var.indices{d});
        % If an ensemble dimension, mutliply by the sequence size
        elseif ~var.isState(d)
            nState(v) = nState(v) .* numel(var.seqDex{d});
        end
    end
    
    % Get the indices
    varDex{v} = k + (1:nState(v))';
    k = max(varDex{v});
end

end