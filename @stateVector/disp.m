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
if isempty(showVariables)
    if ~obj.iseditable
        showVariables = false;
    else
        showVariables = obj.nVariables<=MAXVARS;
    end
end

% Finalized and serialized tags
finalized = '';
if ~obj.iseditable
    finalized = 'finalized ';
end
serialized = '';
if obj.isserialized
    serialized = 'serialized ';
end

% Title
fprintf('  %s%s%s with properties:\n\n', serialized, finalized, link);

% Label (if it exists)
if ~strcmp(obj.label_,"")
    fprintf('        Label: %s\n', obj.label);
end

% Length (if not serialized)
if ~obj.isserialized
    nRows = obj.length;
    fprintf('       Length: %.f rows\n', nRows);
end

% Members (if not 0)
nMembers = obj.members;
if nMembers > 0
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
[sets, nSets] = obj.coupledIndices;
if nSets>0
    if nSets==1
        fprintf('     Coupling: All variables coupled\n\n');
    elseif nSets == obj.nVariables
        fprintf('     Coupling: No variables coupled\n\n');
    else
        fprintf('\n    Coupled Variables:\n');
        obj.dispCoupled(sets);
    end
else
    fprintf('\n');
end

% Link to deserialization
if obj.isserialized
    link = '<a href="matlab:stateVector.deserialize">Deserialize</a>';
    fprintf('  %s to display more details\n\n', link);

% Otherwise, display or link variables if they exist
elseif obj.nVariables>0
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