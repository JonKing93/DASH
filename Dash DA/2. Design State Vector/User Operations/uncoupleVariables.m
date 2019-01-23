function[design] = uncoupleVariables( design, vars, varargin )
%% Uncouples variable indices in a state vector design.
%
% design = uncoupleVariables( design, vars )
% Uncouples a set of variables.
%
% design = uncoupleVariables( design, vars, 'nowarn' )
% Does not notify the user about secondary uncoupled variables.
%
% ---- Inputs -----
% 
% design: A state vector design
%
% vars: The variables being uncoupled.
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

% Mark as uncoupled and get any secondary coupled variables.
[design, v] = relateVars( design, v, 'isCoupled', false, nowarn);

% Notify user of uncoupling
fprintf(['Uncoupled variables ', sprintf('%s, ', design.varName(v)), '\b\b\n']);

end