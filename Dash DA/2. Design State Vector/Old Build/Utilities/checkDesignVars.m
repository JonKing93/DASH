function[varDex] = checkDesignVars( design, vars )
%% Ensures a design contains the vars
%
% varDex: The variable indices
if ~isa( design, 'stateDesign')
    error('design must be a stateDesign object.');
elseif numel(unique(vars)) ~= numel(vars)
    error('Input cannot contain repeated variables.');
end
[ismem, varDex] = ismember(vars, design.var);
if any(~ismember(vars, design.var))
    error('Variable %s is not in the state design.', ...
        vars( find(~ismember(vars,design.var), 1) ));
end
end