function[design] = coupleVariables(design, vars, template, varargin )
%% Couples specified variables in a state vector design.
%
% design = coupleVariables( design, vars, template )
% Couples variables to a template variable.
%
% design = coupleVariables( design, vars, template, 'nowarn' )
% Does not notify the user about secondary coupled variables.
%
% ----- Inputs -----
%
% design: A state vector design
%
% vars: The names of the variables that are being coupled to the template.
%
% template: The name of the template variable.
%
% ----- Outputs -----
%
% design: The updated state vector design.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Parse Inputs
[nowarn] = parseInputs( varargin, {'nowarn'}, {false}, {'b'} );

% Get variable indices
yv = checkDesignVar(design, vars);
xv = checkDesignVar(design, template);
if ~isscalar(xv)
    error('Template must be a single variable.');
end

% Get the full set of variable indices
v = unique([xv; yv],'stable');

% Get the prior relationship of variables
prevCouple = design.isCoupled;

% Mark the variables as coupled and get any secondary coupled variables.
[design, v] = markCoupled( design, v, nowarn);

% Get the ensemble dimensions in the template variable
ensDim = find( ~design.var(xv).isState );

% For each variable that is not the template
for k = 2:numel(v)
    
    % Notify user of coupling
    fprintf(['Coupling variable %s to ', sprintf('%s, ', design.varName(v([1:k-1,k+1:end]))' ), '\b\b\n'],...
        design.varName(v(k)));
    
    % Set the overlap value
    design.var(v(k)).overlap = design.var(xv).overlap;
    if design.var(v(k)).overlap
        fprintf('\tEnabling overlap.');
    end
    
    % If not already coupled to the template
    if ~prevCouple(xv, v(k))
    
        % For each ensemble dimension
        for d = 1:numel( ensDim ) 

            % Get the dimension index in the coupling variable
            dim = checkVarDim( design.var(v(k)), design.var(xv).dimID(ensDim(d)) );

            % Flip the isState toggle to ensemble
            design.var(v(k)).isState(dim) = false;

            % Notify user
            fprintf('\tConverting %s to an ensemble dimension.\n', design.var(xv).dimID(ensDim(d)) );
        end
    end
    
    % Set the default coupler status
    design.defCouple(v(k)) = design.defCouple(xv); 
    
    % Coupler notification
    defStr = 'Enabling';
    if ~design.defCouple(xv)
        defStr = 'Disabling';
    end
    fprintf('\t%s default coupling.\n\n', defStr);
    
end

end