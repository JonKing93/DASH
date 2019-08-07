function[obj] = couple( obj, varNames )
%% Couples specified variables.
%
% design = obj.couple( varNames )
% Couples a set of variables. Ensemble dimensions, overlap permissions, and
% autoCouple status will be set to that of the first listed variable.
%
% If the dimension type of a dimension is changed (from state to ensemble
% or vice versa) for a variable, then all mean and sequence design
% specifications will be deleted. The user will be notified of these changes.
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

% Notify the user when variables not in the initial list are also coupled.
obj.notifySecondaryCoupling( v, vall );

% Get the overlap, ensemble dimensions, and autocoupling settings
overlap = obj.overlap(v(1));
isState = obj.var(v(1)).isState;
autoCouple = obj.autoCouple(v(1));

% For each variable
for k = 1:nVars
    var = vall(k);
    
    % Couple with all the other variables
    obj.isCoupled( var, vall ) = true;
    obj.isCoupled( vall, var ) = true;
    
    % Get the dimensions that are changing type, delete their mean and
    % sequence data. Notify the user.
    flipDim =   isState ~= obj.var(var).isState;
    for d = 1:numel(flipDim)
        dim = flipDim(d);
        obj.var(var).takeMean(dim) = false;
        obj.var(var).meanDex{dim} = [];
        obj.var(var).nanflag{dim} = [];
        obj.var(var).seqDex{dim} = [];
        obj.var(var).seqMeta{dim} = [];
    end
    obj.notifyChangedType( var, flipDim, false );
    
    % Set the autocoupler, overlap, and ensemble dimensions
    obj.autoCouple(var) = autoCouple;
    obj.overlap(var) = overlap;
    obj.var(var).isState = isState;
end

end