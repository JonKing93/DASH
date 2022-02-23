function[] = disp(obj, showVariables)
%% stateVector.disp  Display stateVector object in console

% Parameters
MAXVARS = 10; % The maximum number of variables to display by default

% Parse showVariables
header = "DASH:stateVector:disp";
if ~exist('showVariables','var') || isempty(showVariables)
    showVariables = [];
else
    showVariables = dash.parse.switches(showVariables, {["h","hide"],["s","show"]},...
        1, 'showVariables', 'allowed option', header);
end

% Get the class documentation link
link = '<a href="matlab:dash.doc(''stateVector'')">stateVector</a>';

% If not scalar, display array size and exit
if ~isscalar(obj)
    info = dash.string.nonscalarObj(obj, link);
    fprintf(info);
    return
end

% Set default showVariables
if ~obj.iseditable
    showVariables = false;
else
    showVariables = obj.nVariables<=MAXVARS;
end

% Finalized tag
finalized = '';
if ~obj.iseditable
    finalized = 'finalized ';
end

% Title
fprintf('  %s%s with properties:\n\n', finalized, link);

% Label, Length
if ~strcmp(obj.label_,"")
    fprintf('        Label: %s\n', obj.label);
end
nRows = obj.length;
fprintf('       Length: %.f rows\n', nRows);

% Members for finalized vectors
if ~obj.iseditable
    nMembers = size(obj.subMembers{1}, 1);
    fprintf('      Members: %.f ensemble members\n', nMembers);
end

% Print variables or number of variables
if obj.nVariables==0 || obj.nVariables>MAXVARS
    vars = string(obj.nVariables);
else
    vars = strjoin(obj.variableNames, ', ');
end
fprintf('    Variables: %s\n', vars);

% Coupling information
sets = obj.couplingInfo.sets;
nSets = numel(sets);
if nSets>0
    if nSets==1
        fprintf('     Coupling: All variables coupled\n\n');
    elseif nSets == obj.nVariables
        fprintf('     Coupling: No variables coupled\n\n');
    else
        fprintf('\n    Coupled Variables:\n');
        obj.dispCoupled;
    end
else
    fprintf('\n');
end

% Display or link variables if they exist
if obj.nVariables>0
    name = inputname(1);
    if showVariables
        fprintf('    Vector:\n');
        obj.dispVariables(name);
    else
        link = sprintf('<a href="matlab:%s.dispVariables">Show variables</a>', name);
        fprintf('  %s\n\n', link);
    end
end

end