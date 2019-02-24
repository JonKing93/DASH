function[design] = uncoupleVariables( design, vars, template, varargin )
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

% If the template is a default couple, remove the other variables from the
% default coupling
if design.defCouple(xv)
    design.defCouple(v) = false;
end

% Notify user of uncoupling
fprintf(['Uncoupled variables ', sprintf('%s, ', design.varName(v)'), ...
         'from ', sprintf('%s, ', design.varName(rv)), '\b\b\n\n']);

end