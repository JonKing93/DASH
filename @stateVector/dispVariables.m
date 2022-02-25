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

% Get width format for variable names and number of rows
nRows = string(obj.lengths);
rowsWidth = max(strlength(nRows));
nameWidth = max(strlength(obj.variableNames));
format = sprintf('        %%%.fs - %%%.fs rows', nameWidth, rowsWidth);

% If unserialized, also get dimension details
if ~obj.isserialized
    details = strings(obj.nVariables, 1);
    for v = 1:obj.nVariables
        [sizes, types] = obj.variables_(v).stateSizes;
        types = strcat(types, ' (', string(sizes), ')');
        details(v) = strjoin(types, ' x ');
    end

    % Include details and details link in format
    detailsWidth = max(strlength(details));
    detailsFormat = sprintf('   |   %%-%.fs', detailsWidth);
    link = sprintf('<a href="matlab:%s.variable(%%.f)">Show details</a>', objName);
    format = [format, detailsFormat, link];
end

% Print each variable
format = [format, '\n'];
for v = 1:obj.nVariables
    if obj.isserialized
        args = {obj.variableNames(v), nRows(v)};
    else
        args = {obj.variableNames(v), nRows(v), details(v), v};
    end
    fprintf(format, args{:});
end
fprintf('\n');

% If serialized, link to deserialization
if obj.isserialized
    link = '<a href="matlab:stateVector.deserialize">Deserialize</a>';
    fprintf('  %s to display more details\n\n', link);
end

end