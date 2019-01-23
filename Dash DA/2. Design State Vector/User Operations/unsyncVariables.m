function[design] = unsyncVariables( design, vars, template, varargin )
%% Unsyncs variable indices in a state vector design.
%
% unsyncVariables( design, vars )
% Unsyncs the state, sequence and mean indices of the specified variables.
% Does not uncouple the variables.
%
% unsyncVariables( design, vars, 'nowarn' )
% Does not notify the user about secondary unsynced variables.
%
% ----- Inputs -----
%
% design: A state vector design
%
% vars: A set of variables to unsync
%
% template: The variable from which to unsync
%
% ----- Outputs -----
%
% design: The updated state vector design.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the nowarn toggle
nowarn = parseInputs( varargin, {'nowarn'}, {false}, {'b'} );

% Get the variable indices
v = unique( checkDesignVar(design, vars) );
xv = checkDesignVar(design, template);

% Mark as synced and get any secondary unsynced variables.
[design, rv] = unrelateVars( design, v, xv, 'isSynced', nowarn);

% Notify user of uncoupling
fprintf(['Unsyncing variables ', sprintf('%s, ', design.varName(v)), ...
         'from ', sprintf('%s, ', design.varName(rv)), '\b\b\n\n']);

end