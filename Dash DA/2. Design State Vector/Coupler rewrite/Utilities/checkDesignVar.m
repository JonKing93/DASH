function[varDex] = checkDesignVar( design, var )
%% Ensures a design contains the vars
%
% varDex: The variable indices
if ~isa( design, 'stateDesign')
    error('design must be a stateDesign object.');
end
[ismem, varDex] = ismember(var, design.var);
if any(~ismem)
    error('Variable %s is not in the state design.', var(find(~ismem,1)));
end
end