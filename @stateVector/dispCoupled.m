function[] = dispCoupled(obj, sets)
%% stateVector.dispCoupled  Display coupled variables in the console
% ----------
%   <strong>obj.dispCoupled</strong>(sets)
%   Displays sets of coupled variables in the console. Coupled variables
%   are grouped with one another.
% ----------
%   Inputs:
%       sets (cell vector [nSets] {vector, linear indices}): A
%           cell vector with one element per coupling set. Each element
%           holds the indices of the variables in the coupling set.
%
% <a href="matlab:dash.doc('stateVector.dispCoupled')">Documentation Page</a>

% If there are no variables, exit
nSets = numel(sets);
if nSets==0
    return
end

% Get width for numbering
width = strlength(string(nSets));
format = sprintf('%%%.f.f', width);
format = ['        ',format,'. %s\n'];

% Print each set of variables
for s = 1:nSets
    varNames = obj.variableNames(sets{s});
    fprintf(format, s, strjoin(varNames, ', '));
end
fprintf('\n');

end