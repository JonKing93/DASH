function[obj] = uncouple( obj, varNames )
%% Uncouples variables in a state vector design from all other variables.
%
% design = obj.uncouple( varNames )
% Uncouples a set of variables from all other variables. Disables the
% autocoupler.
%
% ---- Inputs -----
% 
% obj: A state vector design
%
% varNames: The list of variables to uncouple. Either a cellstring or
%           string vector.
%
% ----- Outputs -----
%
% design: The updated state vector design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the indices of the variables in the state vector design
v = obj.findVarIndices( varNames );

% Uncouple each variable from all others
for k = 1:numel(v)
    obj.isCoupled( v(k), : ) = false;
    obj.isCoupled( :, v(k) ) = false;
    
    % But the variable should remain coupled with itself....
    obj.isCoupled( v(k), v(k) ) = true;
    
    % Remove the autocoupler
    obj.autoCouple( v(k) ) = false;
end

end