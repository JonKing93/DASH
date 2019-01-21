function[design] = coupleVariables(design, vars, template, varargin )
%% Couples specified variables in a state vector design.
%
% design = coupleVariables( design, vars, template, nowarn)
%
% ----- Inputs -----
%
% design: A state vector design
%
% vars: The names of the variables that are being coupled.
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Parse Inputs
[nowarn] = parseInputs( varargin, {'nowarn'}, {false}, {'b'} );

% Get variable indices
xv = checkDesignVar(design, template);
yv = checkDesignVar(design, vars);

% Get the full set of variable indices
v = [xv; yv];

% Mark the variables as coupled and get any variables that were coupled to
% the current set.
[design, v] = markSynced( design, v, 'isCoupled', true, nowarn);

% Get the ensemble dimensions in the template variable
ensDim = find( ~design.var(xv).isState );

% For each variable that is not the template
for k = 2:numel(v)
    
    % Notify user of new coupling
    notify = false;
    if ~design.isCoupled(xv, v(k))
        fprintf('Coupling variable %s to %s: \n', design.varName(v(k)), design.varName(xv) );
        notify = true;
    end
    
    % For each ensemble dimension
    for d = 1:numel( ensDim ) 
        
        % Get the dimension index in the coupling variable
        dim = checkVarDim( design.var(v(k)), design.var(xv).dimID{d} );
        
        % Flip the isState toggle to ensemble
        design.var(v(k)).isState(dim) = false;
        
        % Get the overlap value
        design.var(v(k)).overlap(dim) = design.var(xv).overlap(d);
        
        % Notify user
        if notify
            overStr = '';
            if design.var(xv).overlap(d)
                overStr = ' and enabling overlap';
            end
            fprintf('\tConverting %s to an ensemble dimension%s.\n', design.var(xv).dimID{ensDim(d)}, overStr );
        end
    end
end

end