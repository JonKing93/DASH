function[] = disp(obj)
%% optimalSensor.disp  Displays an optimalSensor object in the console
% ----------
%   obj.disp
%   Displays details about an optimal sensor object in the console. Begins
%   by displaying a link to the class documentation. If the object is
%   scalar, displays the label (if there is one). Also displays the current
%   status of the metric, estimates, and uncertainties. Displays
%   assimilation sizes as they are set.
%
%   If the object is an array, displays the array size. If any of the
%   objects in the array have labels, displays the labels. Any object
%   without a label is listed as "<no label>". If the array is empty,
%   declares that the array is empty.
% ----------
%   Outputs:
%       Displays the object in the console.
%
% <a href="matlab:dash.doc('optimalSensor.disp')">Documentation Page</a>

% Get class documentation link
link = '<a href="matlab:dash.doc(''optimalSensor'')">optimalSensor</a>';

% If not scalar, display array size/labels and exit
if ~isscalar(obj)
    displayArray(obj, link);
    return
end

% Title
fprintf('%s with properties:\n\n', link);

% Names for field labels
label = "Label";
uncertainties = "Uncertainties";
estimates = "Estimates";
metric = "Metric";

nSite = "Observation Sites";
nMembers = "Ensemble Members";

% Get the maximum width of the displayed fields. Use to build the labeling format
width = max(strlength([metric, uncertainties, estimates]));
if ~strcmp(obj.label_, "")
    width = max(width, strlength(label));
end
if obj.nSite > 0
    width = max(width, strlength(nSite));
end
if obj.nMembers > 0
    width = max(width, strlength(nMembers));
end
format = sprintf('    %%%.fs: %%s\\n', width);

% Label
if ~strcmp(obj.label_, "")
    fprintf(format, label, obj.label_); %#ok<*CTPCT> 
    fprintf('\n');
end

% Metric
if isempty(obj.J)
    status = 'none';
else
    status = 'set';
end
fprintf(format, metric, status);

% Estimates
if isempty(obj.Ye)
    status = 'none';
else
    status = 'set';
end
fprintf(format, estimates, status);

% Uncertainties
if isnan(obj.Rtype)
    status = 'none';
elseif obj.Rtype==0
    status = 'set (variances)';
elseif obj.Rtype==1
    status = 'set (covariances)';
end
fprintf(format, uncertainties, status);
fprintf('\n');

% Sizes
format = sprintf('    %%%.fs: %%.f\\n', width);
siz = [obj.nSite, obj.nMembers];
if any(siz>0)
    if obj.nSite>0
        fprintf(format, nSite, obj.nSite);
    end
    if obj.nMembers>0
        fprintf(format, nMembers, obj.nMembers);
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