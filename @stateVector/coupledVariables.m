function[names, indices] = coupledVariables(obj)
%% stateVector.coupledVariables  Lists the sets of coupled variables in a state vector
% ----------
%   obj.coupledVariables
%   Prints the sets of coupled variables to the console.
%
%   names = obj.coupledVariables
%   Returns the names of coupled variables in the state vector. The names
%   are organized in a cell vector with one element per set of coupled
%   variables. Each element holds a list of variable names that are coupled
%   to one another.
%
%   [names, indices] = obj.coupledVariables
%   Also returns the indices of the variables in each coupled set.
% ----------
%   Outputs:
%       names (cell vector [nSets] {string vector [nCoupledVariables]}: The
%           names of the variables in each set of coupled variables.
%       indices (cell vector [nSets] {vector, linear indices [nCoupledVariables]}):
%           The indices of the variables in each set of coupled variables.
%           Inidices are relative to each variable's position in the state
%           vector.
%
% <a href="matlab:dash.doc('stateVector.coupledVariables')">Documentation Page</a>

% Get sets of coupled variables
sets = unique(obj.coupled, 'rows', 'stable');
nSets = size(sets, 1);

% Preallocate output
if nargout>0
    names = cell(nSets,1);
    indices = cell(nSets,1);

    % Get names and indices of variables in each set
    for s = 1:nSets
        names{s} = obj.variableNames(sets(s,:));
        indices{s} = find(sets(s,:));
    end
    return
end

% No variables
if nSets==0
    name = char(obj.name);
    name(1) = upper(name(1));
    fprintf('\n    %s has no variables.\n\n', name);

% All coupled
elseif nSets==1
    fprintf('\n    All variables in %s are coupled.\n\n', obj.name);

% No coupling
elseif nSets==obj.nVariables
    fprintf('\n    None of the variables in %s are coupled.\n\n', obj.name);

% Mixed coupling
else
    fprintf('\n    Sets of coupled variables:\n');
    obj.dispCoupled;
end

end