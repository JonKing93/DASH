function[obj, failed, cause] = coupleDimensions(obj, t, vars, header)
%% stateVector.coupleDimensions  Update state and ensemble dimensions of variables to match a template variable
% ----------
%   [obj, failed, cause] = <strong>obj.coupleDimensions</strong>(t, vars, header)
%   Couples the dimensions of indicated variables to match a template
%   variable. If unsuccessful, indicates that the operation failed and
%   returns the cause of the failure.
% ----------
%   Inputs:
%       t (scalar, linear index): The index of the template variable
%       vars (vector, linear indices): The indices of the variables whose
%           dimensions should be coupled to the template variable
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           coupled dimensions or the original object if coupling failed.
%       failed (0 | scalar linear index): Set to 0 if the state vector
%           updated successfully. If unsuccessful returns the index of the
%           variable that failed
%       cause (scalar MException | []): The cause of the failed update, or
%           an empty array if the coupling was successful.
%
% <a href="matlab:dash.doc('stateVector.coupleDimensions')">Documentation Page</a>

% Initialize error handling
failed = 0;
cause = [];
objInitial = obj;

% Exit if there are no variables
if isempty(vars)
    return
end

% Get the template variable and its ensemble dimensions
template = obj.variables_(t);
ensDims = template.dimensions('ensemble');

% Cycle through variables.
for k = 1:numel(vars)
    v = vars(k);
    variable = obj.variables_(v);

    % Sort the variable's dimensions
    varDims = variable.dimensions;
    varStateDims = variable.dimensions('state');
    varEnsDims = variable.dimensions('ensemble');

    % Require the variable to have all template ensemble dimensions
    missing = ~ismember(ensDims, varDims);
    if any(missing)
        failed = v;
        cause = missingDimensionError(obj, t, v, ensDims, missing, header);
        return
    end

    % Get dimensions that have changed type
    toEns = ismember(varStateDims, ensDims);
    toEns = varStateDims(toEns);
    toState = ~ismember(varEnsDims, ensDims);
    toState = varEnsDims(toState);

    % Update the dimensions
    d = variable.dimensionIndices([toState, toEns]);
    type = [ones(numel(toState),1); repmat(2,numel(toEns),1)];
    indices = cell(numel(d), 1);
    try
        obj.variables_(v) = variable.design(d, type, indices, header);

    % Report error and exit if failed
    catch cause
        if ~contains(cause.identifier, 'DASH')
            rethrow(cause);
        end
        failed = v;
        obj = objInitial;
        return
    end
end

% Update variable lengths
obj = obj.updateLengths(vars);

end

function[ME] = missingDimensionError(obj, t, v, ensDims, missing, header)

tName = obj.variables(t);
vName = obj.variables(v);
dim = ensDims(find(missing,1));
add = '<a href="matlab: dash.doc(''gridfile.addDimension'')">add the dimension</a>';

id = sprintf('%s:missingEnsembleDimension', header);
ME = MException(id, [...
    'Cannot update the ensemble dimensions of "%s" to match "%s"\n',...
    'because "%s" is missing the "%s" dimension. You may want\n',...
    'to %s to the gridfile for "%s" and then\n',...
    'rebuild the state vector.\n\ngridfile: %s'], ...
    vName, tName, vName, dim, add, vName, obj.gridfiles(v));
end