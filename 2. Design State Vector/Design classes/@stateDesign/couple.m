function[obj] = couple( obj, varNames )
%% Couples specified variables.
%
% design = obj.couple( varNames )
% Couples a set of variables. Ensemble dimensions, overlap permissions, and
% autoCouple status will be set to that of the first listed variable.
%
% ----- Inputs -----
%
% obj: A stateDesign object.
%
% varNames: A set of variable names. Either a cellstring or string array.
%
% ----- Outputs -----
%
% design: The updated state vector design.
%

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the indices of the variables in the design
v = obj.findVarIndices( varNames );

% Get the set of all variables coupled to the specified variables. Preserve
% the order so that variable 1 remains the template for overlap, ensemble
% dimensions, and autocoupling
[~, vall] = find( obj.isCoupled( v, : ) );
vall = unique( [v; vall], 'stable' );
nVars = numel(vall);

% Warn the user when variables not in the initial list are altered.
warning('Need a warning.');

% Get the overlap, ensemble dimensions, and autocoupling settings
overlap = obj.var(v(1)).overlap;
isState = obj.var(v(1)).isState;
autoCouple = obj.autoCouple(v(1));

% For each variable
for k = 1:nVars
    
    % Mark as coupled with all the variables
    obj.isCoupled( vall(k), vall ) = true;
    obj.isCoupled( vall, vall(k) ) = true;
    
    % Set the overlap, ensemble, and autocouple values
    obj.var( vall(k) ).overlap = overlap;
    obj.var( vall(k) ).isState = isState;
    obj.autoCouple( vall(k) ) = autoCouple;
end

end