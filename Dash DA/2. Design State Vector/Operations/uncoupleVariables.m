function[design] = uncoupleVariables( design, vars, varargin )
%
% uncoupleVariables( design, vars )
% Uncouples two variables and un-syncs state, sequence, and mean indices.
%
% uncoupleVariables( ..., 'state' )
% Unsyncs state indices but leaves the ensemble members coupled
%
% uncoupleVariables( ..., 'seq' )
% Unsysncs sequence indices.
%
% uncoupleVariables( ..., 'mean' )
% Unsyncs mean indices.

% Error check the design and variables
varDex = checkDesignVars( design, vars );

% Parse the inputs
[state, seq, mean] = parseInputs( varargin, {'state','seq','mean'}, {false, false, false}, {'b','b','b'} );

% Decide whether to uncouple the ensembles, or just unsync
ens = false;
if ~state && ~seq && ~mean
    ens = true;
    state = true;
    seq = true;
    mean = true;
end

% Get the coupler fields
coupler = {'isCoupled','coupleState','coupleSeq','coupleMean'};
toggle = {ens, state, seq, mean};

% For each type of index, uncouple the variables
for f = 1:numel(coupler)
    if toggle{f}
        for v = 1:numel(vars)
            design.(coupler{f})( varDex(v), varDex([1:v-1, v+1:end]) ) = false;
        end
    end
end
end