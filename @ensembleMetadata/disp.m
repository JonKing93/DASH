function[] = disp(obj)
%% ensembleMetadata.disp  Displays an ensembleMetadata object in the console
% ----------
%   <strong>disp</strong>(obj)
%   <strong>obj.disp</strong>
%   Displays an ensembleMetadata object in the console. If scalar,
%   indicates the size of the described state vector ensemble, and the
%   variables in the ensemble. Includes a link to display the ensemble
%   dimensions of each variable.
%
%   If empty, indicates the object is empty and prints its size. If an
%   array of ensembleMetadata objects, prints the size of the array and the
%   labels of the ensembleMetadata objects. Unlabeled elements are marked as
%   "<no label>". Does not print labels if every object is unlabeled.
% ----------
%   Inputs:
%       obj (ensembleMetadata object): The ensembleMetadata object to
%           display in the console
%
%   Prints:
%       Prints the contents of an ensembleMetadata array to the console
%
% <a href="matlab:dash.doc('ensembleMetadata.disp')">Documentation Page</a>

%% Parameters
MAXVARS = 10;  % The maximum number of variables to display by default
%%%

% Get the class documentation link
link = '<a href="matlab:dash.doc(''ensembleMetadata'')">ensembleMetadata</a>';

% If not scalar, display array size and files
if ~isscalar(obj)
    displayArray(obj, link);

% Otherwise, display contents of state vector ensemble
else
    displayScalar(obj, inputname(1), link, MAXVARS);
end

end

%% Utilities
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
function[] = displayScalar(obj, name, link, maxVars)

% Title
fprintf('  %s with properties:\n\n', link);

% Label
if ~strcmp(obj.label_, "")
    fprintf('        Label: %s\n', obj.label_);
end

% Variable names or number of variables
nVars = obj.nVariables;
if nVars==0 || nVars>maxVars
    vars = string(nVars);
else
    vars = strjoin(obj.variables, ', ');
end
fprintf('    Variables: %s\n', vars);

% Length and members
fprintf('       Length: %.f\n', obj.length);
fprintf('      Members: %.f\n\n', obj.nMembers);

% Display or link variables
if nVars > 0
    if nVars <= maxVars
        fprintf('    Vector:\n');
        obj.dispVariables;

    % Link variables
    else
        link = sprintf('<a href="matlab:%s.dispVariables">Show state vector</a>', name);
        fprintf('  %s\n', link);
    end
end

% Link ensemble dimensions
link = sprintf('<a href="matlab:%s.dispEnsemble">Show ensemble dimensions</a>', name);
fprintf('  %s\n\n', link);

end