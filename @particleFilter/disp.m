function[] = disp(obj)
%% particleFilter.disp  Displays a particle filter in the console
% ----------
%
% ----------

% Get class documentation link
link = '<a href="matlab:dash.doc(''particleFilter'')">particleFilter</a>';

% If not scalar, display array size/labels and exit
if ~isscalar(obj)
    displayArray(obj, link);
    return
end

% Title
fprintf('%s with properties:\n\n', link);

% Label
if ~strcmp(obj.label_, "")
    fprintf('            Label: %s\n\n', obj.label_);
end

% Observations
if isempty(obj.Y)
    details = 'none';
else
    details = 'set';
end
fprintf('     Observations: %s\n', details);

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
fprintf('            Prior: %s\n', details);

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
fprintf('        Estimates: %s\n', details);

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
fprintf('    Uncertainties: %s\n\n', details);

% Sizes
siz = [obj.nSite, obj.nState, obj.nMembers, obj.nPrior, obj.nTime];
if any(siz>0)
    if obj.nSite>0
        fprintf('      Observation Sites: %.f\n', obj.nSite);
    end
    if obj.nState>0
        fprintf('    State Vector Length: %.f\n', obj.nState);
    end
    if obj.nMembers>0
        fprintf('       Ensemble Members: %.f\n', obj.nMembers);
    end
    if obj.nPrior>0
        fprintf('                 Priors: %.f\n', obj.nPrior);
    end
    if obj.nTime>0
        fprintf('             Time Steps: %.f\n', obj.nTime);
    end
    fprintf('\n');
end

% Weighting Scheme
if obj.weightType==0
    details = 'Bayesian';
else
    details = sprintf('Best %.f particles', obj.weightArgs{1});
end
fprintf('    Weighting scheme: %s\n\n', details);

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