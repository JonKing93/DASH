function[design] = uncoupleVariables( design, vars, varargin )
%% Uncouples variable indices in a state vector design. Uncoupled variables
% cannot be synced, so also unsyncs variables.
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
warnArg = {};
if nowarn
    warnArg = {'nowarn'};
end

% Get the variable indices
v = unique( checkDesignVar(design, vars) );
xv = checkDesignVar(design, template);

% Mark as uncoupled and get any secondary coupled variables.
[design, rv] = unrelateVars( design, v, xv, 'isCoupled', nowarn);

% Uncoupled variables cannot be synced, so unsync from any variables that
% were uncoupled.
for k = 1:numel(rv)
    design = unsyncVariables( design, design.varName(v), design.varName(rv(k)), warnArg{:} );
end

% Notify user of uncoupling
fprintf(['Uncoupled variables ', sprintf('%s, ', design.varName(v)'), ...
         'from ', sprintf('%s, ', design.varName(rv)), '\b\b\n']);

end