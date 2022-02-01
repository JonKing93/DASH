function[obj, failed, cause] = coupleDimensions(obj, t, vars, header)
%% stateVector.coupleDimensions  Update state and ensemble dimensions of variables to match a template variable
% ----------
%   [obj, failed, cause] = obj.coupleDimensions(t, vars, header)
%   Couples the dimensions of indicated variables to match a template
%   variable. If unsuccessful, indicates that the operation failed and
%   returns the cause of the failure.
% ----------
% ? maybe use uv instead of t to improve error messages

% Initialize error handling
failed = 0;
cause = [];

% Get the template variable and its ensemble dimensions
template = obj.variables_(t);
ensDims = template.dims(~template.isState);

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
    type = [true(numel(toState),1);  false(numel(toEns),1)];
    indices = cell(numel(d), 1);
    try
        obj.variables_(v) = variable.design(d, type, indices, header);

    % Report error and exit if failed
    catch cause
        if ~contains(cause.identifier, 'DASH')
            rethrow(cause);
        end
        failed = v;
        return
    end
end

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