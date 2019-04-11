function[varDim, dimDex] = getVarSize( var, varargin )
%
% dimSize = getVarSize
% All dimensions using sequence elements for ensemble dimensions
%
% dimSize = getVarSize( 'state' )
% Just the state dimensions
%
% dimSize = getVarSize( 'ens' )
% Just the ensemble dimensions
%
% dimSize = getVarSize( 'seq' )
% Ensemble size via number of sequence elements
%
% dimSize = getVarSize( 'ensDex' )
% Ensemble size via number of ensemble indices

% Parse Inputs
[stateOnly, ensOnly, seq, ensDex] = parseInputs( varargin, {'stateOnly','ensOnly','seq','ensDex'}, ...
    {false, false, false, false}, {'b','b','b','b'} );

% Throw errors
if stateOnly && ensOnly
    error('Both stateOnly and ensOnly flags were selected.');
elseif seq && ensDex
    error('Both seq and ensDex flags were selected.');
elseif ~seq && ~ensDex
    seq = true;
end

% Get the dimensions
if stateOnly
    dimDex = find( var.isState );
elseif ensOnly
    dimDex = find( ~var.isState );
else
    dimDex = 1:numel(var.dimID);
end

% Preallocate the dimension size
varDim = NaN( size(dimDex) );

% For each dimension
for dim = 1:numel(dimDex)
    d = dimDex(dim);
    
    % If a state dimension without a mean, the number of state indices
    if var.isState(d) && ~var.takeMean(d)
        varDim(dim) = numel( var.indices{d} );
        
    % State dimension with a mean, only a single value
    elseif var.isState(d) && var.takeMean(d)
        varDim(dim) = 1;
        
    % Ensemble dimension with sequence indices
    elseif ~var.isState(d) && seq
        varDim(dim) = numel( var.seqDex{d} );
        
    % Ensemble dimension with ensemble indices
    elseif ~var.isState(d) && ensDex
        varDim(dim) = numel( var.indices{d} );
       
    % Throw error for incorrect flags.
    else
        error('Unbalanced flags.');
    end
end

end