function[varDex] = checkDesignVar( design, var )
%% Ensures a design contains the vars
%
% varDex: The variable indices
if ~isa( design, 'stateDesign')
    error('design must be a stateDesign object.');
end
[ismem, varDex] = ismember(var, design.varName);
if any(~ismem)
    error('Variable is not in the state design.', var(find(~ismem,1)));
end
end