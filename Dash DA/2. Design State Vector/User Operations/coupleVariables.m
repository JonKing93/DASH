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
%
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
v = unique([xv; yv]);

% Mark the variables as coupled and get any secondary coupled variables.
[design, v] = relateVars( design, v, 'isCoupled', nowarn);

% Get the ensemble dimensions in the template variable
ensDim = find( ~design.var(xv).isState );

% For each variable that is not the template
for k = 2:numel(v)
    
    % Notify user of coupling
    fprintf(['Coupling variable %s to ', sprintf('%s, ', design.varName(v([1:k-1,k+1:end]))' ), '\b\b\n']);
    
    % If not already coupled to the template
    if ~design.isCoupled(xv, v(k))
    
        % For each ensemble dimension
        for d = 1:numel( ensDim ) 

            % Get the dimension index in the coupling variable
            dim = checkVarDim( design.var(v(k)), design.var(xv).dimID{d} );

            % Flip the isState toggle to ensemble
            design.var(v(k)).isState(dim) = false;

            % Set the overlap value
            design.var(v(k)).overlap(dim) = design.var(xv).overlap(d);

            % Notify user
            if design.var(xv).overlap(d)
                overStr = ' and enabling overlap';
            end
            fprintf('\tConverting %s to an ensemble dimension%s.\n', design.var(xv).dimID{ensDim(d)}, overStr );
        end
    end
end

end