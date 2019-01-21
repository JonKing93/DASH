function[design] = checkCopyMeta( design, yvar, xvar, dim )
%% Checks if a variable meets the conditions to copy ensemble dimension
% metadata. Copies if allowed.

% Get the variable indices
xv = checkDesignVar(design, xvar);
yv = checkDesignVar(design, yvar);

% Get the dimension index
xd = checkVarDim( design.var(xv), dim);
yd = checkVarDim( design.var(yv), dim);

% If both seq and mean are synced AND the ensemble dimension metadata are
% empty AND the variables are coupled
if design.syncSeq(xv,yv) && design.syncMean(xv,yv) && design.isCoupled(xv,yv) && ...
        isempty( design.var(yv).ensMeta(yd) )
    
    % Couple the metadata
    design.var(yv).ensMeta(yd) = design.var(xv).ensMeta(xd);
    
    % Notify the user
    fprintf('Copying ensMeta for %s in variable %s from variable %s.\n', dim, yvar, xvar);
end

end