function[] = dispCoupled(obj)
%% stateVector.dispCoupled  Display coupled variables in the console

% Get sets of coupled variables
sets = unique(obj.coupled, 'rows', 'stable');
nSets = size(sets,1);

% If there are no variables, exit
if nSets==0
    return
end

% Get width for numbering
width = strlength(string(nSets));
format = sprintf('%%%.f.f', width);
format = ['        ',format,'. %s\n'];

% Print each set of variables
for s = 1:nSets
    varNames = obj.variableNames(sets(s,:));
    fprintf(format, s, strjoin(varNames, ', '));
end
fprintf('\n');

end