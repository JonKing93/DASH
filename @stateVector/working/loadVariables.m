function[X] = loadVariables(vLimit, members)

% Get the variables to load
vars = vLimit(1):vLimit(2);
nVars = numel(vars);

% Get the number of state vector elements covered each the variables
nState = NaN(nVars, 1);
for k = 1:nVars
    v = vars(k);
    nState(k) = obj.variables_(v).nState;
end

% Get size of loaded matrix
nRows = sum(nState);
nCols = numel(members);

% Preallocate. Flag for error handling if too big for memory
try
    X = NaN(nRows, nCols);
catch
    error('DASH:stateVector:buildEnsemble:arrayTooBig', '');
end

% Find the rows of each variable in the loaded matrix
limits = dash.indices.limits(nState);
for k = 1:nVars
    v = vars(k);
    rows = limits(k,1):limits(k,2);

    % Get the ensemble members to load
    s = coupledVars.whichSet(v);
    subMembers = obj.subMembers{s}(members, :);

    % Load each variable
    variable = obj.variables_(v);
    g = grids.whichGrid(v);
    X(rows,:) = variable.loadMembers(subMembers, grids.grids(g), varSettings(v));
end

end