function[design] = coupleVariables(design, var, template, varargin)
%% Couples variable indices in a state vector design.
%
% design = coupleVariables( design, var, template )
% Couples the ensemble, state, sequence, and mean indices of two variables.
%
% design = coupleVariables( ..., 'nostate' )
% Does not couple state indices.
%
% design = coupleVariables( ..., 'noseq' )
% Does not couple sequence indices.
%
% design = coupleVariables( ..., 'nomean' )
% Does not couple mean indices.
%
% ----- Inputs -----
%
% design: A state vector design
%
% var: The name of the variable that is being coupled to another variable.
%
% template: The name of the template variable. This is the variable to
%      which the first variable is being coupled.
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Parse the synced variable inputs
[syncState, syncSeq, syncMean] = parseInputs( varargin, {'nostate','noseq','nomean'}, {true, true, true}, {'b','b','b'} );

% Get the variables
xv = checkDesignVar(design, template);
template = design.var(xv);

yv = checkDesignVar(design, var);
var = design.var(yv);

% Get the x metadata
xmeta = template.meta;

% For each dimension of X
for d = 1:numel(template.dimID)
    
    % If a state dimension and need to sync state dimensions.
    if template.isState(d) && syncState
        
        % Get the state indices for Y
        index = getCoupledStateIndex( var, template.dimID{d}, xmeta.(template.dimID{d})(template.indices{d}) );
        takeMean = template.takeMean(d);
        nanflag = template.nanflag{d};
        
        % Set the state indices
        design = stateDimension( design, var.name, template.dimID{d}, index, takeMean, nanflag );
    
    % If an ensemble dimension
    else
        
        % Get the ensemble indices
        index = getCoupledEnsIndex( var, template.dimID{d}, xmeta.(template.dimID{d})(template.indices{d}) );
        
        % Get synced ensemble properties
        [seq, mean, nanflag] = getSyncedProperties( template, var, template.dimID{d}, syncSeq, syncMean );
        
        % Set the ensemble indices
        design = ensDimension( design, var.name, template.dimID{d}, index, seq, mean, nanflag, template.ensMeta{d} );
    end
end

% Mark the variables as coupled
design = markCoupled( design, xv, yv, syncState, syncSeq, syncMean );
end