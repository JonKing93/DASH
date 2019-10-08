function[obj] = getVariables( obj, varNames )
%% Gets the part of a state design associated with specified variables
%
% design = obj.getVariables( varNames )
%
% ----- Inputs -----
%
% varNames: A list of variable names.
%
% ----- Outputs ----
%
% design: The stateDesign associated with the specified variables.

% Get the variables, check they are allowed
v = obj.findVarIndices( varNames );

% Get the part of the design associated with the variables
obj.var = obj.var(v);
obj.varName = obj.varName(v);
obj.allowOverlap = obj.allowOverlap(v);
obj.isCoupled = obj.isCoupled(v,v);
obj.autoCouple = obj.autoCouple(v);

end