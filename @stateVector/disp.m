function[] = disp(obj, showVariables)
%% stateVector.disp  Display stateVector object in console
% ----------
%   <strong>obj.disp</strong>
%   Displays a stateVector object in the console. Begins display with a
%   link to the stateVector documentation page. For a scalar stateVector
%   object, lists the label and length, along with a list of variables and
%   coupling status of the state vector. If the state vector contains 10 or
%   less variables, displays the number of rows and dimensional properties
%   associated with each variable. Also links to additional details for the
%   variables. If there are more than 10 variables, provides a link to
%   variable details. Also notes if the stateVector is serialized.
%
%   If a stateVector array, notes the size of the array. If empty,
%   indicates that the array is empty. If any of the elements in the array
%   are labeled, displays the labels of the array elements. Elements
%   without labels are marked by "<no label>".
%
%   <strong>obj.disp</strong>(showVariables)
%   <strong>obj.disp</strong>(true | 's' | 'show')
%   <strong>obj.disp</strong>(false | 'h' | 'hide')
%   Indicate whether variables or not to display variables in the console.
% ----------
%   Inputs:
%       showVariables (scalar logical | string scalar): Whether or not to
%           display variables for the state vector.
%           [true|"s"|"show"]: Displays variables in the console
%           [false|"h"|"hide"]: Does not display variables in the console
%
%   Prints:
%       Displays the contents of a stateVector object or array to the console
%
% <a href="matlab:dash.doc('stateVector.disp')">Documentation Page</a>

%%% Parameters
MAXVARS = 10; % The maximum number of variables to display by default
%%%

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
    displayArray(obj, link);
    return
end

% Set default showVariables
if isempty(showVariables)
    showVariables = obj.nVariables<=MAXVARS;
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

% Label, Length, Members
if ~strcmp(obj.label_,"")
    fprintf('        Label: %s\n', obj.label);
end
fprintf('       Length: %.f rows\n', obj.length);
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

% Display or link variables if they exist
if obj.nVariables>0
    objName = inputname(1);
    if showVariables
        fprintf('    Vector:\n');
        obj.dispVariables(objName);
    else
        link = sprintf('<a href="matlab:%s.dispVariables">Show variables</a>', objName);
        fprintf('  %s\n\n', link);
    end
end

end

% Utility functions
function[] = displayArray(obj, link)

% Display array size
info = dash.string.nonscalarObj(obj, link);
fprintf(info);

% Exit if empty
if isempty(obj)
    return
end

% Collect labels
labels = strings(size(obj));
for k = 1:numel(obj)
    labels(k) = obj(k).label_;
end

% Display labels
unlabeled = strcmp(labels, "");
if ~all(unlabeled, 'all')
    fprintf('    Labels:\n');
    labels(unlabeled) = "<no label>";
    if ismatrix(labels)
        fprintf('\n');
    end
    disp(labels);
end

end