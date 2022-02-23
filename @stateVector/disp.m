function[] = disp(obj)
%% stateVector.disp  Display stateVector object in console

% Parameters
MAXVARS = 5; % The maximum number of variables to sketch by default

% Get the class documentation link
link = '<a href="matlab:dash.doc(''stateVector'')">stateVector</a>';

% If not scalar, display array size and exit
if ~isscalar(obj)
    info = dash.string.nonscalarObj(obj, link);
    fprintf(info);
    return
end

% Title
fprintf('  %s with properties:\n\n', link);

% Label, Length
if ~strcmp(obj.label_,"")
    fprintf('        Label: %s\n', obj.label);
end
nRows = obj.length;
fprintf('       Length: %.f rows\n', nRows);

% Print variables or number of variables
if obj.nVariables==0 || obj.nVariables>MAXVARS
    vars = string(obj.nVariables);
else
    vars = strjoin(obj.variableNames, ', ');
end
fprintf('    Variables: %s\n\n', vars);

% Display variables if not too many
if obj.nVariables>0 && obj.nVariables<=MAXVARS
    obj.dispVariables;

% Otherwise, link to the variables
else
    link = sprintf('<a href="matlab:%s.dispVariables">Show variables</a>', inputname(1));
    fprintf('  %s\n\n', link);
end

end