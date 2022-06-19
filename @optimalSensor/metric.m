function[varargout] = metric(obj, type, varargin)
%% optimalSensor.metric  Specify a metric for the optimal sensor
% ----------
%   [J, details] = obj.metric
%   Calculates and returns the initial sensor metric from the prior. Also
%   returns details about the type of calculation used to calculate the
%   metric, and any additional parameters for the calculation.
%
%   obj = obj.metric(type, ...)
%   Indicate how the optimal sensor should calculate a test metric from
%   the prior. By default, if the prior has a single state vector row, the
%   optimal sensor will use the prior directly as the metric. Thus, this
%   method is not necessary if you provided the metric directly as the
%   prior. Instead, use this method if the prior contains multiple state
%   vector rows. The syntaxes for different types of metrics are detailed
%   below.
%
%   obj = obj.metric('reset')
%   Resets the type of metric for the optimal sensor. This includes a
%   "direct" metric set by default when using a prior with a single row.
%   The optimal sensor object will no longer have a metric, so a metric
%   will need to be specified before running any optimal sensor algorithms.
%
%   obj = obj.metric('direct')
%   Uses the prior directly as the metric. This option is selected by
%   default when the prior contains a single row. You can only select this
%   option if the prior contains a single row.
%
%   obj = obj.metric('mean')
%   obj = obj.metric(..., 'rows', rows)
%   obj = obj.metric(..., 'weights', weights)
%   obj = obj.metric(..., 'nanflag', nanOption)
%   Calculates the metric as a mean over state vector elements. Use the
%   "rows" flag to only implement the mean over specific state vector rows.
%   If you do not provide the "rows" flag, takes a mean over all state
%   vector elements. Use the "weights" flag to implement a weighted mean
%   over the selected state vector elements (otherwise, implements a
%   standard unweighted mean). Use the "nanflag" flag to indicate how to
%   treat NaN values in the state vector when taking a mean. If you do not
%   specify the "nanflag" option, includes NaN elements in the mean.
% ----------
%   Inputs:
%       type (string scalar): Indicates the type of calculation to use to
%           determine the optimal sensor metric.
%           ['direct']: Use the prior directly as the metric.
%           ['mean']: Calculate the metric using a mean over state vector elements
%       rows (logical vector [nState] | vector linear indices [nRows]): Indicates
%           which state vector rows to use in the weighted mean. If a
%           logical vector, must have one element per state vector row. If
%           not set, selects every row in the state vector.
%       weights (numeric vector [nRows]): The weights to use for a weighted
%           mean of the selected state vector elements. Must have one
%           element per state vector row used in the mean. If you provided
%           a "rows" input, the order of weights must match the order of
%           input rows. Otherwise, the order of weights should match the
%           order of elements in the state vector.
%       nanOption (string scalar | scalar logical): Indicates how to treat
%           NaN elements in a state vector when taking a mean.
%           ["omitnan"|false]: Omits NaN values when taking means
%           ["includenan"|true (default)]: Includes NaN values when taking means
% 
%   Outputs:
%       obj (scalar optimalSensor object): The optimal sensor object with
%           updated metric options
%       J (numeric row vector): The initial sensor metric used in any
%           optimal sensor algorithms.
%       details (scalar struct): Details about the type of calculation used
%           to calculate a metric from the prior.
%
% <a href="matlab:dash.doc('optimalSensor.metric')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:metric";
dash.asserrt.scalarObj(obj, header);

% Calculate and return metric. Require prior and metric type
if ~exist('type','var')
    if isempty(obj.X)
        noPriorError;
    elseif isnan(obj.metricType)
        unspecifiedMetricError;
    end

    % Compute the metric
    varargout = {obj.computeMetric};

    % Optionally include details
    if nargout>1
        details = struct;
        if obj.metricType==0
            details.type = 'direct';
        elseif obj.metricType==1
            details.type = 'mean';
            [rows, weights, nanflag] = obj.metricArgs{1:3};
            if ~isempty(rows)
                details.rows = rows;
            end
            if ~isempty(weights)
                details.weights = weights;
            end
            details.nanflag = nanflag;
        end
        varargout{2} = details;
    end
    return
end

% Check the type
type = dash.assert.strflag(type, 'The first input', header);
allowed = ["reset", "direct", "mean"];
dash.assert.strsInList(type, allowed, 'The first input', 'recognized option', header);

% Reset
if strcmpi(type, 'reset')
    if numel(varargin)>0
        dash.error.tooManyInputs;
    end
    
    obj.metricType = NaN;
    obj.metricArgs = {};
    varargout = {obj};
    return
end

% Require a prior when setting the metric. Get the number of rows
if isnan(obj.Xtype)
    noPriorError;
elseif obj.Xtype == 0
    nRows = size(obj.X, 1);
elseif obj.Xtype == 1
    nRows = obj.X.length;
end

% Direct metric
if strcmpi(type, 'direct')
    if numel(varargin)>0
        dash.error.tooManyInputs;
    end

    % Only allow a single row
    if nRows ~= 1
        tooManyRowsError;
    end

    % Set the metric
    obj.metricType = 0;
    obj.metricArgs = {};

% Mean metric. Parse inputs
elseif strcmpi(type, 'mean')
    flags = ["rows", "weights", "nanflag"];
    defaults = {[], [], 'includenan'};
    [rows, weights, nanflag] = dash.parse.nameValue(varargin, flags, defaults, 1, header);

    % Initialize the metric
    obj.metricType = 1;
    obj.metricArgs = cell(1, 3);

    % Error check the rows
    if ~isempty(rows)
        logicalReq = 'have one element per state vector row';
        linearMax = 'the number of rows in the state vector';
        rows = dash.assert.indices(rows, nRows, 'rows', logicalReq, linearMax, header);
        obj.metricArgs{1} = rows(:);
        nRows = numel(rows);
    end

    % Error check the weights
    if ~isempty(weights)
        dash.assert.vectorTypeN(weights, 'numeric', nRows, 'weights', header);
        dash.assert.defined(weights, 2, 'weights', header);
        obj.metricArgs{2} = weights(:);
    end

    % Parse the nanflag, save string
    switches = {"omitnan","includenan"}; %#ok<CLARRSTR> 
    includenan = dash.parse.switches(nanflag, switches, 1, 'nanOption', header);
    if includenan
        nanoption = "includenan";
    else
        nanoption = "omitnan";
    end
    obj.metricArgs{3} = nanoption;
end

% Return the updated object
varargout = {obj};

end