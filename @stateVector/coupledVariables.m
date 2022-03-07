function[varargout] = coupledVariables(obj, variables)
%% stateVector.coupledVariables  Lists the sets of coupled variables in a state vector
% ----------
%   obj.coupledVariables
%   obj.coupledVariables(0)
%   Prints the sets of coupled variables to the console.
%
%   [namesInSets, indicesInSets] = obj.coupledVariables
%   ... = obj.coupledVariables(0)
%   Returns the names of coupled variables in the state vector. The names
%   are organized in a cell vector with one element per set of coupled
%   variables. Each element holds a list of variable names that are coupled
%   to one another. Also returns the indices of the variables in each
%   coupled set.
%
%   obj.coupledVariables(-1)
%   obj.coupledVariables(v)
%   obj.coupledVariables(variableNames)
%   Prints the sets of variables that are coupled to each of the listed
%   variables. If the first input is -1, prints the variables coupled to
%   every vector in the state vector.
%
%   [names, indices] = obj.coupledVariables(-1)
%   [names, indices] = obj.coupledVariables(v)
%   [names, indices] = obj.coupledVariables(variableNames)
%   Returns the names and indices of variables that are coupled to each of
%   the listed variables. If the first input is -1, returns information for
%   every variable in the state vector.
% ----------
%   Inputs:
%       v (logical vector | vector [nVariables], linear indices): The indices
%           of the variables for which to return coupled variables.
%       variableNames (string vector [nVariables]): The names of the variables in the 
%           state vector for for which to return coupled variables
%
%   Outputs:
%       namesInSets (cell vector [nSets]{string vector [nCoupledVariables]}:
%           The names of the variables in each set of coupled variables.
%       indicesInSets (cell vector [nSets] {vector, linear indices [nCoupledVariables]}):
%           The indices of the variables in each set of coupled variables.
%           Inidices are relative to each variable's position in the state
%           vector.
%       names (cell vector [nVariables]{string vector [nCoupledVariables]}:
%           The names of the variables coupled to each listed variable.
%       indices (cell vector [nVariables]{vector, linear indices [nCoupledVariables]}):
%           The indices of the variables coupled to each listed variable.
%
% <a href="matlab:dash.doc('stateVector.coupledVariables')">Documentation Page</a>

% Setup
header = "DASH:stateVector:coupledVariables";
dash.assert.scalarObj(obj, header);

%% Returning set information
if ~exist('variables','var') || isequal(variables, 0)
    
    % Get sets of coupled variables
    [sets, nSets] = obj.coupledIndices;

    % Build output
    varargout = {};
    if nargout>0
        names = cell(nSets, 1);
        for s = 1:nSets
            names{s} = obj.variableNames(sets{s});
        end
        varargout = {names, sets};

    % Print output
    elseif nSets==0
        fprintf('\n    %s has no variables.\n\n', obj.name(true));
    elseif nSets==1
        fprintf('\n    All variables in %s are coupled.\n\n', obj.name);
    elseif nSets==obj.nVariables
        fprintf('\n    None of the variables in %s are coupled.\n\n', obj.name);
    else
        fprintf('\n    Sets of coupled variables:\n');
        obj.dispCoupled(sets);
    end

%% Returning variable information
else

    % Error check variables.
    if isequal(variables, -1)
        vars = 1:obj.nVariables;
    else
        vars = obj.variableIndices(variables, true, header);
    end

    % Preallocate
    nVars = numel(vars);
    indices = cell(nVars, 1);
    names = cell(nVars, 1);

    % Get names and indices of coupled variables
    for k = 1:nVars
        v = vars(k);
        coupled = obj.coupled(v,:);
        coupled(v) = false;
        indices{k} = find(coupled);
        names{k} = obj.variableNames(indices{k});
    end

    % Return output
    varargout = {};
    if nargout>0
        varargout = {names, indices};

    % Print output. Get width format
    elseif nVars>0
        varNames = obj.variableNames(vars);
        width = max(strlength(varNames));
        format = sprintf('        %%%.fs: ', width);

        % Print information for each variable
        fprintf('\n    Coupled Variables:\n');
        for v = 1:nVars
            list = dash.string.list(names{v});
            fprintf([format,'%s\n'], varNames(v), list);
        end
        fprintf('\n');
    end
end

end