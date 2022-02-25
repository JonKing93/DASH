function[] = dispVariables(obj, objName)
%% stateVector.dispVariables  Display a list of state vector variables in the console

% Default name
if ~exist('objName','var') || isempty(objName)
    objName = inputname(1);
end

% Exit if there are no variables
if obj.nVariables==0
    fprintf('        No variables\n\n');
    return
end

% Get the number of rows for each variable and dimension details
details = strings(obj.nVariables, 1);
for v = 1:obj.nVariables
    [sizes, types] = obj.variables_(v).stateSizes;
    types = strcat(types, ' (', string(sizes), ')');
    details(v) = strjoin(types, ' x ');
end

% Get width formats
nameWidth = max(strlength(obj.variableNames));
nRows = string(obj.lengths);
rowsWidth = max(strlength(nRows));
detailsWidth = max(strlength(details));
format = sprintf('        %%%.fs - %%%.fs rows   |   %%-%.fs   ', ...
    nameWidth, rowsWidth, detailsWidth);

% Include dimension info and details link
link = sprintf('<a href="matlab:%s.variable(%%.f)">Show details</a>', objName);
format = [format, link, '\n'];

% Print each variable
for v = 1:obj.nVariables
    fprintf(format, obj.variableNames(v), nRows(v), details(v), v);
end
fprintf('\n');

end