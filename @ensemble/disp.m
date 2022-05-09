function[] = disp(obj, scope)
%% ensemble.disp  Display an ensemble object in the console
% ----------
%   obj.disp
%   Displays the ensemble object in the console. If scalar, indicates
%   whether the ensemble is static or evolving. Also indicates the size of
%   used variables and ensemble members, and any evolving ensembles.
%   Includes links to display the used state vector and the saved ensemble
%   in the .ens file.
%
%   If empty, indicates the object is empty and prints its size. If an
%   array of ensemble objects, prints the size of the array and the labels
%   of the ensemble objects. Unlabeled ensemble objects are marked as 
%   "<no label>". If all the ensemble objects are unlabeled, displays the
%   .ens files instead.
%
%   obj.disp(scope)
%   Indicate whether to display contents saved in the .ens file, or values
%   used by the ensemble object. If printing file contents, prints the
%   details and size of all variables saved in the .ens file. Includes a
%   link to display the saved state vector. If an array, displays the
%   .ens files associated with the objects, and never the labels.
% ----------
%   Inputs:
%       scope (string scalar | logical scalar): The scope for which to
%           print ensemble information
%           ["used"|"u"|true (default)]: Print information about the
%               contents of the .ens file being used by the object
%           ["file"|"f|false]: Print information about the saved contents
%               of the .ens file.
%
%   Outputs:
%       Prints information about an ensemble object to the console.
%
% <a href="matlab:dash.doc('ensemble.disp')">Documentation Page</a>

%%% Parameters
MAXVARS = 10;    % The maximum number of variables to display by default
MAXEVOLVE = 5;  % The maximum number of evolving ensembles to display by default
%%%

% Parse the scope
header = "DASH:ensemble:disp";
if ~exist('scope','var')
    useFile = false;
else
    useFile = ensemble.parseScope(scope, header);
end

% Get the class documentation link
link = '<a href="matlab:dash.doc(''ensemble'')">ensemble</a>';

% If not scalar, display array size and labels/files
if ~isscalar(obj)
    displayArray(obj, link, useFile);

% Otherwise, display file contents or used contents
elseif useFile
    dispFile(obj, inputname(1), link, MAXVARS);
else
    dispUsed(obj, inputname(1), link, MAXVARS, MAXEVOLVE)
end

end

function[] = dispFile(obj, name, link, maxVars)

% Title
fprintf('  saved %s with properties:\n\n', link);

% File
fprintf('    File: %s\n\n', obj.file);

% Variables or number of variables
nVars = obj.nVariables('file');
if nVars <= maxVars
    vars = obj.variables(-1, 'file');
    vars = strjoin(vars, ', ');
else
    vars = string(nVars);
end
fprintf('    Saved Variables: %s\n', vars);

% Length and members
fprintf('       Total Length: %.f\n', obj.length(0, 'file'));
fprintf('      Saved Members: %.f\n\n', obj.totalMembers);

% Link to saved vector
link = sprintf('<a href="matlab:%s.dispVariables(true)">Show saved state vector</a>', name);
fprintf('  %s\n\n', link);

end
function[] = dispUsed(obj, name, link, maxVars, maxEvolve)

% Static and evolving tags
type = 'static';
if obj.isevolving
    type = 'evolving';
end

% Title
fprintf('  %s %s with properties:\n\n', type, link);

% Label, variables, length, static members
if ~strcmp(obj.label_, "")
    fprintf('        Label: %s\n', obj.label_);
end

% Variable names or number of variables
nVars = obj.nVariables;
if nVars <= maxVars
    vars = strjoin(obj.variables, ', ');
else
    vars = string(obj.nVariables);
end
fprintf('    Variables: %s\n', vars);

% Length and members
fprintf('       Length: %.f\n', obj.length);
fprintf('      Members: %.f\n', obj.nMembers);
fprintf('\n');

% Evolving ensembles
if obj.isevolving
    fprintf('    Evolving Ensembles: %.f\n', obj.nEvolving);

    % Check for evolving labels
    labels = obj.evolvingLabels;
    haslabels = ~all(strcmp(labels, ""));
    if haslabels

        % Either display labels or link
        if obj.nEvolving < maxEvolve
            obj.dispEvolving;
        else
            link = sprintf('<a href="matlab:%s.dispEvolving">Show labels</a>', name);
            fprintf('    %s\n\n', link);
        end

    % Otherwise end the section
    else
        fprintf('\n');
    end
end

% Add link to display state vector and file contents
link = sprintf('<a href="matlab:%s.dispVariables">Show state vector</a>', name);
fprintf('  %s\n', link);
link = sprintf('<a href="matlab:%s.disp(''file'')">Show .ens file contents</a>', name);
fprintf('  %s\n\n', link);

end

%% Utilities
function[] = displayArray(obj, link, showFile)

    % Display the array size
    info = dash.string.nonscalarObj(obj, link);
    fprintf(info);

    % If not showing file, collect labels
    if ~showFile
        labels = strings(size(obj));
        for k = 1:numel(labels)
            labels(k) = obj(k).label;
        end
        unlabeled = strcmp(labels, "");
    end

    % If showing file, or labels are empty, collect files
    if showFile || all(unlabeled)
        files = strings(size(obj));
        for k = 1:numel(files)
            files(k) = obj(k).file;
        end
        showFile = true;
    end

    % Display files or labels
    if showFile
        fprintf('    Files:\n\n')
        disp(files);
    else
        labels(unlabeled) = "<no label>";
        fprintf('    Labels:\n\n')
        disp(labels);
    end

end