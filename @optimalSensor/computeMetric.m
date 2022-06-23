function[J] = computeMetric(obj, allowNaN)
%% optimalSensor.computeMetric  Computes the sensor metric from the prior
% ----------
%   J = obj.computeMetric
%   Cmoputes the sensor metric from the prior. If the sensor metric
%   contains NaN values, throws an error.
%
%   J = obj.computeMetric(allowNaN)
%   Indicate whether to allow NaN values in the metric.
% ----------
%   Inputs:
%       allowNaN (scalar logical): True if the sensor metric is allowed to
%           contain NaN values. If false (default), throws an error when
%           the metric contains NaN values.
%
%   Outputs:
%       J (numeric row vector [nMembers]): The sensor metric
%
% <a href="matlab:dash.doc('optimalSensor.computeMetric')">Documentation Page</a>

% Default
if ~exist('allowNaN','var')
    allowNaN = false;
end

% Get the rows of the prior that are needed
if obj.metricType==1 && ~obj.metricDetails.defaultRows
    rows = obj.metricDetails.rows;
else
    rows = (1:obj.nState)';
end

% Load the prior from a matrix or ensemble object
if obj.Xtype==0
    X = obj.X(rows,:);
else
    try
        X = obj.X.loadRows(rows);

    % Informative error if the ensemble object failed
    catch cause
        if ~startsWith(cause.identifier, 'DASH')
            rethrow(cause);
        end
        ME = priorFailedError(obj, cause, header);
        throwAsCaller(ME);
    end
end

% Get the metric directly
if obj.metricType==0
    J = X;

% Get the metric from a mean
elseif obj.metricType==1
    nanflag = obj.metricDetails.nanflag;
    weights = obj.metricDetails.weights;

    % Unweighted
    if obj.metricDetails.defaultWeights
        J = mean(X, 1, nanflag);

    % Weighted include nan
    elseif strcmp(nanflag, "includenan")
        J = sum(weights.*X, 1) ./ sum(weights);

    % Weighted omit nan
    elseif strcmp(nanflag, "omitnan")
        nans = isnan(X);
        if any(nans, 'all')
            weights = repmat(weights, 1, nMembers);
            weights(nans) = NaN;
        end
        J = sum(weights.*X, 1, "omitnan") ./ sum(weights, 1, "omitnan");
    end
end

% Optionally throw error for NaN metric
if ~allowNaN
    ME = nanMetricError;
    throwAsCaller(ME);
end

end

%% Error messages









