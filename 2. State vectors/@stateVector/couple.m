function[obj] = couple(obj, varNames)
%% Couples variables in a state vector. Adjusts dimensions of coupled
% variables to match the state and ensemble dimensions of the first listed
% variable.
%
% obj = obj.couple(varNames)
%
% ----- Inputs -----
%
% varNames: A list a variable names to be coupled. A string vector or
%    cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Glossary of indices
% uv: User variables
% v: All variables being coupled
% sv: Secondary variables being coupled (those not listed by the user)
% t: Template variable (first user variable)

% Error check. Get the indices of user variables. Get names for messages
uv = obj.checkVariables(varNames);
allNames = obj.variableNames;

% Get the template variable and its ensemble dimensions
t = uv(1);
ensDims = obj.variables(t).dims( ~obj.variables(t).isState );

% Find all variables coupled to those listed. Note any secondary coupled
% variables.
[~, col] = find(obj.coupled(uv,:));
v = unique(col);
sv = v(~ismember(v, uv));
notifySecondaryVariables(obj.verbose, allNames, sv, t);

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
    
    % Change the dimension types. Notify user of changes.
    obj.variables(v(k)) = var.design(toEns, 'ensemble');
    obj.variables(v(k)) = var.design(toState, 'state');
    notifyChangedDimensions(obj.verbose, allNames, v(k), t, toEns, toState);
    
    % Couple the variable to the others
    obj.coupled(v, v(k)) = true;
    obj.coupled(v(k), v) = true;
end

end

% Messages
function[] = notifySecondaryVariables(verbose, names, sv, t)

% No message if no secondary variable, or user disabled messages
if ~isempty(sv) && verbose
    
    % Plural vs singular variables
    plural = ["s", "were"];
    if numel(sv)==1
        plural = ["", "was"];
    end
    
    % Format variables as string
    template = names(t);
    names = dash.messageList( names(sv) );
    
    % Message
    fprintf(['\nVariable%s %s %s previously coupled to %s. Thus, %s will also be ', ...
        'coupled to %s.\n'], plural(1), names, plural(2), names, template);
end

end
function[] = notifyChangedDimensions(verbose, names, v, t, toEns, toState)

% Only notify if dimensions are changing and user has not disabled messages
if verbose && (numel(toEns)>0 || numel(toState)>0)
    fprintf('\nCoupling variable "%s" to "%s":\n', names(v), names(t));

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