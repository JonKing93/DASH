function[] = dispCoupled(obj)
%% stateVector.dispCoupled  Display coupled variables in the console

% Get coupling sets
sets = obj.couplingInfo.sets;
nSets = numel(sets);

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
    v = sets(s).vars;
    varNames = obj.variableNames(v);
    fprintf(format, s, strjoin(varNames, ', '));
end
fprintf('\n');

end