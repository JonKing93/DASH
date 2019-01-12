function[design] = uncoupler( design, vars, varargin )

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