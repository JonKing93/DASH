function[] = dispCoupled(obj, sets)
%% stateVector.dispCoupled  Display coupled variables in the console

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