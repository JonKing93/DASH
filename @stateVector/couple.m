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

% Error check. Get the indices of user variables and template variable.
obj.assertEditable;
uv = obj.checkVariables(varNames);
t = uv(1);

% Find all variables coupled to those listed. Note any secondary coupled
% variables.
[~, col] = find(obj.coupled(uv,:));
v = unique(col);
sv = v(~ismember(v, uv));
notifySecondaryVariables(obj, uv, sv, t);

% Update the coupled variables to match the template
obj = obj.updateCoupledVariables(t, v);

% Couple the variables to one another
for k = 1:numel(v)
    obj.coupled(v, v(k)) = true;
    obj.coupled(v(k), v) = true;
end

end

% Message
function[] = notifySecondaryVariables(obj, uv, sv, t)

% No message if no secondary variable, or user disabled messages
if ~isempty(sv) && obj.verbose
    
    % Plural vs singular variables
    plural = ["s", "are"];
    if numel(sv)==1
        plural = ["", "is"];
    end
    
    % Format variable names as string
    names = obj.variableNames;
    template = names(t);
    input = dash.string.messageList( names(uv) );
    secondary = dash.string.messageList( names(sv) );
    
    % Message
    fprintf(['\nVariable%s %s %s coupled to %s. Thus, %s will also be ', ...
        'coupled to "%s".\n'], plural(1), secondary, plural(2), input, secondary, template);
end

end