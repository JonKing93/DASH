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

% Parse the inputs
[state, ens, seq, mean] = parseInputs( varargin, {'state','ens','seq','mean'}, {false, false, false, false}, {'b','b','b','b'} );

% Determine which indices to uncouple
toggle = getUncouplerSwitches(state, ens, seq, mean);

% Get the variable indices
varDex = checkDesignVar(design, vars);

% Get the field names
field = {'isCoupled','coupleState','coupleSeq','coupleMean'};

% For each field being uncoupled
for f = 1:numel(field)
    if toggle(f)
        
        % Uncouple each variable
        for v = 1:numel(varDex)
            design.(field{f})(v, [1:v-1, v+1:end]) = false;
        end
    end
end

end