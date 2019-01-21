function[design] = coupleVariables(design, vars, nowarn)
%% Couples specified variables in a state vector design.
%
% design = coupleVariables( design, vars, nowarn)
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

% Get variable indices
v = checkDesignVar(design, vars);

% Get the nowarn toggle
if ~exist('nowarn','var')
    nowarn = false;
elseif strcmpi(nowarn, 'nowarn')
    nowarn = true;
else
    error('Unrecognized input.');
end

% Mark the variables as coupled
design = markSynced( design, v, 'isCoupled', nowarn);
end