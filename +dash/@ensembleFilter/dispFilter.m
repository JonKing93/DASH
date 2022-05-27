function[width] = dispFilter(obj, link, width)
%% ensembleFilter.dispFilter  Displays details about an ensembleFilter in the console
% ----------
%   width = obj.dispFilter(link, width)
%   Displays details about an ensembleFilter object in the console. Begins
%   by displaying a link to the class documentation. If the object
%   is scalar, displays the label (if there is one). Also displays the current
%   status of the observations, estimates, uncertainties, and prior.
%   Displays assimilation sizes as they are set. Aligns labels to match the
%   same width.
%
%   If the object is an array, displays the array size. If any of the
%   objects in the array have labels, displays the labels. Any object
%   without a label is listed as "<no label>". If the array is empty,
%   declares that the array is empty.
% ----------
%   Inputs:
%       link (string scalar): Class documentation link
%       width (scalar positive integer | []): The maximum width of labels
%           in subclass disp methods. Only used for scalar display.
%
%   Outputs:
%       width (scalar positive integer): The maximum width for aligning
%           fields after also considering dispFilter fields.
%
%   Outputs:
%       Displays the object in the console
%
% <a href="matlab:dash.doc('ensembleFilter.dispFilter')">Documentation Page</a>

% If not scalar, display array size/labels and exit
if ~isscalar(obj)
    displayArray(obj, link);
    return
end

% Title
fprintf('%s with properties:\n\n', link);

% Names for field labels
label = "Label";
observations = "Observations";
uncertainties = "Uncertainties";
prior = "Prior";
estimates = "Estimates";

nSite = "Observation Sites";
nState = "State Vector Length";
nMembers = "Ensemble Members";
nPrior = "Priors";
nTime = "Time Steps";

% Get the maximum width of the displayed fields
maxWidth = max(strlength([observations, uncertainties, prior, estimates]));
if ~strcmp(obj.label_, "")
    maxWidth = max(maxWidth, strlength(label));
end
if obj.nSite > 0
    maxWidth = max(maxWidth, strlength(nSite));
end
if obj.nState > 0
    maxWidth = max(maxWidth, strlength(nState));
end
if obj.nMembers > 0
    maxWidth = max(maxWidth, strlength(nMembers));
end
if obj.nPrior > 0
    maxWidth = max(maxWidth, strlength(nPrior));
end
if obj.nTime > 0
    maxWidth = max(maxWidth, strlength(nTime));
end
width = max(width, maxWidth);

% Get the labeling format for the widths
format = sprintf('    %%%.fs: %%s\\n', width);

% Label
if ~strcmp(obj.label_, "")
    fprintf(format, label, obj.label_); %#ok<*CTPCT> 
    fprintf('\n');
end

% Observations
if isempty(obj.Y)
    details = 'none';
else
    details = 'set';
end
fprintf(format, observations, details);

% Prior
if isempty(obj.X)
    details = 'none';
elseif obj.nPrior==1
    details = 'static';
elseif isequal(obj.whichPrior(:), (1:obj.nTime)')
    details = 'evolving  (one per time step)';
else
    details = sprintf('evolving  (%.f priors)', obj.nPrior);
end
fprintf(format, prior, details);

% Estimates
if isempty(obj.Ye)
    details = 'none';
elseif obj.nPrior==1
    details = 'set';
elseif isequal(obj.whichPrior(:), (1:obj.nTime)')
    details = 'evolving  (one set per time step)';
else
    details = sprintf('evolving  (%.f priors)', obj.nPrior);
end
fprintf(format, estimates, details);

% Uncertainties
if isempty(obj.R)
    details = 'none';
elseif obj.Rtype==0
    details = 'variances';
elseif obj.Rtype==1
    details = 'covariances';
end
if obj.nR>1
    if isequal(obj.whichR(:), (1:obj.nR)')
        details = sprintf('%s  (one set per time step)', details);
    else
        details = sprintf('%s  (%.f sets)', details, obj.nR);
    end
end
fprintf(format, uncertainties, details);
fprintf('\n');

% Sizes
format = sprintf('    %%%.fs: %%.f\\n', width);
siz = [obj.nSite, obj.nState, obj.nMembers, obj.nPrior, obj.nTime];
if any(siz>0)
    if obj.nSite>0
        fprintf(format, nSite, obj.nSite);
    end
    if obj.nState>0
        fprintf(format, nState, obj.nState);
    end
    if obj.nMembers>0
        fprintf(format, nMembers, obj.nMembers);
    end
    if obj.nPrior>0
        fprintf(format, nPrior, obj.nPrior);
    end
    if obj.nTime>0
        fprintf(format, nTime, obj.nTime);
    end
    fprintf('\n');
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