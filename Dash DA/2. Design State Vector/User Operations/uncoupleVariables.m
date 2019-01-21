function[design] = uncoupleVariables( design, vars, varargin )
%% Uncouples variable indices in a state vector design.
%
% design = uncoupleVariables( design, {var1, var2, ..., varN} )
% Uncouples the ensemble, state, sequence, and mean indices of a set a
% variables.
%
% design = uncoupleVariables( design, {var1, var2, ..., varN}, 'state' )
% Only uncouples the state indices of a set of variables.
%
% design = uncoupleVariables( design, {var1, var2, ..., varN}, 'seq' )
% Only uncouples the sequence indices of a set of variables.
%
% design = uncoupleVariables( design, {var1, var2, ..., varN}, 'mean' )
% Only uncouples the mean indices of a set of variables.
%
% design = uncoupleVariables( design, {var1, var2, ..., varN}, 'ens' )
% Uncouples the ensemble, mean, and sequence indices for a set of variables
%
% ---- Inputs -----
% 
% design: A state vector design
%
% varN: The name of the Nth variable to uncouple.
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the variable indices
v = checkDesignVar(design, vars);

% Uncouple
design = markSynced( design, v, 'isCoupled', false, true);

end