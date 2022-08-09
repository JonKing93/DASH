function[info] = couplingInfo(obj)
%% stateVector.couplingInfo  Return organized information about coupled variables
% ----------
%   info = <strong>obj.couplingInfo</strong>
%   Returns a struct with information about coupled variables in the
%   current state vector
% ----------
%   Outputs:
%       info (scalar struct): Information about coupling
%           .sets (struct vector [nSets]): Information about each set of coupled variables
%               .vars (vector, linear indices [nVariables]): The indices of
%                       variables in a set of coupled variables
%               .ensDims (string vector [nDimensions]): The names of the
%                       ensemble dimensions in the coupling set
%               .dims (matrix, linear indices [nVariables x nDimensions]):
%                   The indices of the ensemble dimensions for the
%                   variables in the set
%           .variables (struct vector [nVariables]): Coupling information for each variable
%               .whichSet (scalar, linear index): The index of the coupling
%                       set to which the variable belongs
%               .dims (vector, linear indices [nDimensions]): The indices
%                       of the ensemble dimensions in the variable
%
% <a href="matlab:dash.doc('stateVector.couplingInfo')">Documentation Page</a>

% Get the sets of coupled variables
[indices, nSets] = obj.coupledIndices;

% Preallocate sets and variables
sets = struct('vars', NaN(0,1), 'ensDims', strings(1,0), 'dims', []);
sets = repmat(sets, [nSets, 1]);
variables = struct('whichSet', NaN, 'dims', NaN(0,1));
variables = repmat(variables, [obj.nVariables, 1]);

% Get ensemble dimensions and indices for each set
for s = 1:nSets
    variable1 = obj.variables_(indices{s}(1));
    ensDims = variable1.dimensions('ensemble');
    dims = obj.dimensionIndices(indices{s}, ensDims);

    % Record set information
    sets(s).vars = indices{s};
    sets(s).ensDims = ensDims;
    sets(s).dims = dims;

    % Also organize info for each variable
    nVars = numel(indices{s});
    for k = 1:nVars
        v = indices{s}(k);
        variables(v).whichSet = s;
        variables(v).dims = dims(k,:);
    end
end

% Combine sets and variables
info = struct('sets', sets, 'variables', variables);

end