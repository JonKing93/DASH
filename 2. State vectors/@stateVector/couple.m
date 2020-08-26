function[obj] = couple(obj, varNames)
%% Couples variables in a state vector. Adjusts dimensions of coupled
% variables to match the state and ensemble dimensions of the first listed
% variable.
%
% obj = obj.couple(varNames)

% Error check the variables, get the indices, names, and template
userVars = obj.checkVariables(varNames, true);
allNames = obj.variableNames;
t = userVars(1);

% Find all variables coupled to those listed and note any secondary
% variables not in the user list
[~, col] = find(obj.coupled(userVars,:));
coupleVars = unique(col);
secondary = coupleVars( ~ismember(coupleVars, userVars) );

% Notify the user of secondary variables being coupled
secondaryNotification(obj.verbose, allNames, secondary, varNames, allNames(t));

% Get the ensemble dimensions from the template variable
ensDims = obj.variables(t).dims( ~obj.variables(t).isState );

% Couple each variable to the other variables
for cv = 1:numel(coupleVars)
    v = coupleVars(cv);
    obj.coupled(v, coupleVars) = true;
    obj.coupled(coupleVars, v) = true;
    var = obj.variables(v);
    
    % Check that the variable has all required dimensions
    missing = ~ismember(ensDims, var.dims);
    if missing
        error('Cannot couple variable "%s" to template variable "%s" because %s does not have the ensemble dimension "%s".', var.name, allNames(t), var.name, ensDims(find(missing,1)) );
    end
    
    % Determine if any dimensions will change type.
    varEnsDims = var.dims(~var.isState);
    varStateDims = var.dims(var.isState);
  
    changeToState = varEnsDims(~ismember(varEnsDims, ensDims));
    changeToEns = varStateDims(ismember(varStateDims, ensDims));
    
    % Optionally notify user
    notifyChangedDims(obj.verbose, allNames(v), allNames(t), changeToState, changeToEns);
    
    % Change the types
    d = var.checkDimensions(changeToState);
    var.changeToState(d);
    
    d = var.checkDimensions(changeToEns);
    var.changeToEns(d);
end
    
    
    

end

function[] = secondaryNotification(verbose, allNames, secondary, varNames, templateName)
% Optionally notify the user about secondary variable coupling.
if verbose
    fprintf('Variables(s) %s were previously coupled to %s, so will also be coupled to %s.\n\n', ...
        dash.errorStringList(allNames(secondary)), dash.errorStringList(varNames), templateName);
end
end