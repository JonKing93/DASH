function[varDex] = checkDesignVar( design, var )
%% Ensures a design contains the vars
%
% varDex: The variable indices

% Check there is a variable design
if ~isa( design, 'stateDesign') || ~isscalar(design)
    error('design must be a scalar stateDesign object.');
end

% Ensure the variable is a string
var = string(var);

% Get the variable location
[ismem, varDex] = ismember(var, design.varName);

% Check every variable is present
if any(~ismem)
    error('Variable %s is not in the ''%s'' state vector design.', var(find(~ismem,1)), design.name );
end

% Convert to column
varDex = varDex(:);

end