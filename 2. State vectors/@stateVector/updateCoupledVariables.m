function[obj] = updateCoupledVariables(obj, t, v)
%% Updates variables to match the ensemble dimensions of a template variable
%
% obj = obj.updateCoupledVariables(t, v)
%
% ----- Inputs -----
%
% t: The index of the template variable
%
% v: The indices of variables being updated to match the template
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Get the ensemble dimensions of the template
ensDims = obj.variables(t).dims( ~obj.variables(t).isState );

% Check each variable has the required dimensions
for k = 1:numel(v)
    var = obj.variables(v(k));
    missing = ~ismember(ensDims, var.dims);
    if any(missing)
        missingDimsError();
    end
    
    % Check if any state dimensions need to be converted to ensemble, and
    % vice versa. Notify user of changes.
    varStateDims = var.dims(var.isState);
    toEns = varStateDims( ismember(varStateDims, ensDims) );
    varEnsDims = var.dims(~var.isState);
    toState = varEnsDims( ~ismember(varEnsDims, ensDims) );
    
    % Change the dimension types. Notify user of changes. Save
    var = var.design(toEns, 'ensemble');
    var = var.design(toState, 'state');
    notifyChangedDimensions(obj, v(k), t, toEns, toState);
    obj.variables(v(k)) = var;
end

end

% Error message
function[] = notifyChangedDimensions(obj, v, t, toEns, toState)

% Only notify if dimensions are changing and user has not disabled messages
if obj.verbose && (numel(toEns)>0 || numel(toState)>0)
    template = obj.variables(t).name;
    thisVar = obj.variables(v).name;
    fprintf('\nCoupling variable "%s" to "%s":\n', thisVar, template);

    % Converting to ensemble.
    nEns = numel(toEns);
    if nEns>0
        plural = ["state dimensions", "ensemble dimensions"];
        if nEns == 1
            plural = ["a state dimension", "an ensemble dimension"];
        end
        fprintf('\tConverting %s from %s to %s.\n', dash.messageList(toEns), plural(1), plural(2));
    end
    
    % Converting to state
    nState = numel(toState);
    if nState>0
        plural = ["ensemble dimensions", "state dimensions"];
        if nState == 1
            plural = ["an ensemble dimension", "a state dimension"];
        end
        fprintf('\tConverting %s from %s to %s.\n', dash.messageList(toState), plural(1), plural(2));
    end
end

end