function[] = dispEnsemble(obj)

% Exit if there are no variables
if obj.nVariables == 0
    return
end

% Title
fprintf('    Ensemble Dimensions:\n');

% Get width format for variable names
nameWidth = max(strlength(obj.variables_));
format = sprintf('        %%%.fs - %%s\n', nameWidth);

% Get dimension details
details = strings(obj.nVariables, 1);
for v = 1:obj.nVariables
    s = obj.couplingSet(v);
    ensDims = obj.ensembleDimensions{s};
    if isempty(ensDims)
        details(v) = "";
    else
        details(v) = strjoin(ensDims, ', ');
    end
end

% Print each variable
for v = 1:obj.nVariables
    fprintf(format, obj.variables_(v), details(v));
end
fprintf('\n');

end