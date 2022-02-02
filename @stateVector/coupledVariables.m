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

% Get coupling info
sets = obj.couplingInfo.sets;
nSets = numel(sets);

% Preallocate as output
if nargout>0
    names = cell(nSets,1);
    indices = cell(nSets,1);

    % Get items in each set
    for s = 1:nSets
        names{s} = obj.variables(sets(s).vars);
        indices{s} = sets(s).vars;
    end
    return
end

% Print to console
fprintf('\n');

% No variables
if nSets==0
    message = sprintf('%s has no variables.', obj.name);
    message(1) = upper(message(1));
    fprintf('%s\n', message);
    return

% % Everything coupled to one another
% elseif nSets==1
%     fprintf('All variables are coupled to one other.\n');
%     return
end

% Multiple sets. Get width for numbering
fprintf('Sets of coupled variables:\n');
maxnum = sprintf('%.f', nSets);
width = numel(maxnum);
count = sprintf('%%%.f.f', width');
format = sprintf('\\t%s. %%s\\n', count);

% Print each set
for s = 1:nSets
    varNames = obj.variables(sets(s).vars);
    fprintf(format, s, dash.string.list(varNames));
end
fprintf('\n');

end