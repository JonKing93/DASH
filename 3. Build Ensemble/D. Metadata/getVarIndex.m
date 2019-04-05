function[varDex] = getVarIndex( design )
%% Gets indices of each variable in a state vector. Also returns the total
% number of state elements
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Preallocate state indices for each variable
nVar = numel(design.var);
varDex = cell(nVar,1);

% Get an increment to count indices
k = 0;

% For each variable
for v = 1:nVar
    var = design.var(v);
    
    % Initialize the number of elements
    nEls = 1;
    
    % Multiply by the number of elements along each dimension.
    for d = 1:numel(var.dimID)
        
        % If a state dimension and not a mean, mutliply by the number of
        % state elements
        if var.isState(d) && ~var.takeMean(d)
            nEls = nEls .* numel(var.indices{d});
            
        % If a state dimension and taking a mean, singleton dimension. Just
        % multiplying by 1 so do nothing.
        
        % If an ensemble dimension, multiply by the number of sequence elements
        elseif ~var.isState(d)
            nEls = nEls .* numel(var.seqDex{d});
        end
    end
    
    % Get the indices
    varDex{v} = k + (1:nState(v))';
    k = max(varDex{v});
end

end