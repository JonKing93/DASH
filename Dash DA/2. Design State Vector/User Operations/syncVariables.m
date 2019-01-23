function[design] = syncVariables( design, vars, template, varargin )
%% Syncs variables in a state vector design. 
%
% design = syncVariables( design, vars, template )
% Syncsthe state, sequence, and/or mean indices of variables to a
% template variable. Couples all variables if not previously coupled.
% If a synced variable lacks metadata for the ensemble dimensions, copies
% the ensMeta field from the template variable.
%
% design = syncVariables( ..., 'nowarn' )
% Does not notify the user about secondary variables.
%
% design = syncVariables( ..., 'nocopy' )
% Never copies metadata from the ensMeta field.
%
% ----- Inputs -----
%
% design: A state vector design
%
% vars: The names of the variables being synced
%
% template: The name of the template variable
%
% ----- Outputs -----
%
% design: The updated state vector design
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Parse the inputs
[nowarn, nocopy] = parseInputs( varargin, {'nowarn','nocopy'}, {false, false}, {'b','b'} );

% Get the template variable and synced variables
yv = unique( checkDesignVar(design, vars) );
xv = checkDesignVar( design, template );
if ~isscalar(xv)
    error('Template must be a single variable.');
end

% Get the full set of variable indices
v = unique([xv;yv]);

% Mark as synced and get any secondary synced variables
[design, v] = relateVars( design, v, 'isSynced', true, nowarn );

% Get the template and sync variables
X = design.var(xv);
Y = design.var(v(2:end));

% For each sync variable
for k = 1:numel(Y)
    
    % For each template dimension
    for dim = 1:numel(X.dimID)
        
        % Get a dimension index for the sync variable
        d = checkVarDim( Y(k), X.dimID{dim} );
        
        % Get values for means
        Y(k).takeMean(d) = X.takeMean(dim);
        Y(k).nanflag{d} = X.nanflag{dim};
        
        % If a state dimension
        if X.isState(dim)
            
            % Flip the isState toggle
            Y(k).isState(d) = true;
            
            % Get the state indices with matching metadata
            Y(k).indices{d} = getMatchingMetaDex( Y(k), X.dimID{dim}, X.meta.(X.dimID{dim})(X.indices{dim}) );
            
        % If an ensemble dimension and syncing seq or mean
        else
            
            % Flip the isState toggle
            Y(k).isState(d) = false;
            
            % Get the sequence and mean indices
            Y(k).seqDex{d} = X.seqDex{dim};
            Y(k).meanDex{d} = X.meanDex{dim};
            
            % Copy metadata if appropriate
            if ~nocopy && isempty( Y(k).ensMeta{d} )
                Y(k).ensMeta{d} = X.ensMeta{dim};
            end
        end
    end
end

end