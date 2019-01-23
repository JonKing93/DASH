function[design] = unsyncVariables( design, vars, varargin )
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

% Mark as synced and get any secondary unsynced variables.
[design, v] = relateVars( design, v, 'isSynced', false, nowarn);

% Notify user of uncoupling
fprintf(['Unsyncing variables ', sprintf('%s, ', design.varName(v)'), '\b\b\n']);

end