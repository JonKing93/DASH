function[obj] = updateCoupledVariables(obj, t, vars, header)

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
        missingDimensionError;
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
    obj.variables_(v) = variable.design(d, type, indices, header);
end

end