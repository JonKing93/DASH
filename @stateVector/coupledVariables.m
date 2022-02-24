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
[sets, nSets] = obj.coupledIndices;

% Build output
if nargout>0
    names = cell(nSets,1);
    indices = sets;
    for s = 1:nSets
        names{s} = obj.variableNames(sets{s});
    end
    return
end

% Print info: no variables, all coupled, none coupled, multiple sets
if nSets==0
    fprintf('\n    %s has no variables.\n\n', obj.name(true));
elseif nSets==1
    fprintf('\n    All variables in %s are coupled.\n\n', obj.name);
elseif nSets==obj.nVariables
    fprintf('\n    None of the variables in %s are coupled.\n\n', obj.name);
else
    fprintf('\n    Sets of coupled variables:\n');
    obj.dispCoupled(sets);
end

end