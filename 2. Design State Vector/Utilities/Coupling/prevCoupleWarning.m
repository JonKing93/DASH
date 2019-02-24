function[] = prevCoupleWarning( var, secondVar )
%% Warns the user for secondary variables being synced or coupled.
%
% var: The variable name
%
% secondVar: Names of secondary variables
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019
   
% Warning message
fprintf(['Coupling ', sprintf('%s, ',[var, secondVar]), '\b\b.\n']);

end