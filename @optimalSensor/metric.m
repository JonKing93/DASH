function[varargout] = metric(obj, type, varargin)
%% optimalSensor.metric  Specify a metric for the optimal sensor
% ----------
%   [J, details] = obj.metric
%   Calculates and returns the initial sensor metric from the prior. Also
%   returns details about the type of calculation used to calculate the
%   metric, and any additional parameters for the calculation. This syntax
%   will return the initial sensor metric even when the metric contains NaN
%   values. Thus, this method can be used to search for NaN values in the
%   computed sensor metric.
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
        noPriorForCalculationError(obj, header);
    elseif isnan(obj.metricType)
        unspecifiedMetricError(obj, header);
    end

    % Compute the metric
    J = obj.computeMetric(true);
    varargout = {J};

    % Optionally include details
    if nargout>1
        details = struct;

        % Direct metric details
        if obj.metricType==0
            details.type = "direct";

        % Mean metric details
        elseif obj.metricType==1
            details.type = "mean";
            if ~obj.metricDetails.defaultRows
                details.rows = obj.metricDetails.rows;
            end
            if ~obj.metricDetails.defaultWeights
                details.weights = obj.metricDetails.weights;
            end
            details.nanflag = obj.metricDetails.nanflag;
        end

        % Return metric and details. Exit
        varargout{2} = details;
    end
    return
end

% Check the type
type = dash.assert.strflag(type, 'The first input', header);
allowed = ["reset", "direct", "mean"];
dash.assert.strsInList(type, allowed, 'The first input', 'recognized option', header);

% Reset. Don't allow following inputs
if strcmpi(type, 'reset')
    if numel(varargin)>0
        dash.error.tooManyInputs;
    end
    
    % Reset metric and exit
    obj.metricType = NaN;
    obj.metricDetails = struct;
    obj.userMetric = true;
    varargout = {obj};
    return
end

% Require a prior when setting the metric. Get the number of rows
if isnan(obj.Xtype)
    noPriorError(obj, header);
elseif obj.Xtype == 0
    nRows = size(obj.X, 1);
elseif obj.Xtype == 1
    nRows = obj.X.length;
end

% Direct metric. Don't allow additional inputs and require a single row
if strcmpi(type, 'direct')
    if numel(varargin)>0
        dash.error.tooManyInputs;
    elseif nRows ~= 1
        tooManyRowsError(obj, nRows, header);
    end

    % Get the type and details
    type = 0;
    details = struct;

% Mean metric. Parse inputs
elseif strcmpi(type, 'mean')
    flags = ["rows", "weights", "nanflag"];
    defaults = {[], [], 'includenan'};
    [rows, weights, nanflag] = dash.parse.nameValue(varargin, flags, defaults, 1, header);

    % Get type, initialize details
    type = 1;
    details = struct('rows',[], 'weights',[], 'nanflag',[], 'defaultRows',[], 'defaultWeights',[]);

    % Default or error check rows
    if isempty(rows)
        isdefault = true;
        rows = [];
    else
        isdefault = false;
        logicalReq = 'have one element per state vector row';
        linearMax = 'the number of rows in the state vector';
        rows = dash.assert.indices(rows, nRows, 'rows', logicalReq, linearMax, header);
    end
    details.rows = rows;
    details.defaultRows = isdefault;

    % Deafult or error check weights
    if isempty(weights)
        isdefault = true;
        weights = [];
    else
        isdefault = false;
        dash.assert.vectorTypeN(weights, 'numeric', nRows, 'weights', header);
        dash.assert.defined(weights, 2, 'weights', header);
    end
    details.weights = weights;
    details.defaultWeights = isdefault;

    % Parse the nanflag, save as string
    switches = {"omitnan","includenan"}; %#ok<CLARRSTR> 
    includenan = dash.parse.switches(nanflag, switches, 1, 'nanOption', header);
    if includenan
        nanflag = "includenan";
    else
        nanflag = "omitnan";
    end
    details.nanflag = nanflag;
end

% Update the object and return as output
obj.metricType = type;
obj.metricDetails = details;
obj.userMetric = true;
varargout = {obj};

end

%% Error messages
function[] = noPriorForCalculationError(obj, header)
link = '<a href="matlab:dash.doc(''optimalSensor.prior'')">optimalSensor.prior</a>';
id = sprintf('%s:noPrior', header);
ME = MException(id, ['Cannot calculate the initial sensor metric because ',...
    'you have not yet provided a prior for %s. See the %s command to provide ',...
    'a prior.'], obj.name, link);
throwAsCaller(ME);
end
function[] = unspecifiedMetricError(obj, header)
id = sprintf('%s:unspecifiedMetric', header);
ME = MException(id, ['Cannot calculate the initial sensor metric because ',...
    'you have not yet specified the type of metric for %s.'], obj.name);
throwAsCaller(ME);
end
function[] = noPriorError(obj, header)
link = '<a href="matlab:dash.doc(''optimalSensor.prior'')">optimalSensor.prior</a>';
id = sprintf('%s:noPrior', header);
ME = MException(id, ['You cannot specify a metric for %s because you have ',...
    'not yet provided a prior. See the %s command to provide a prior.'], ...
    obj.name, link);
throwAsCaller(ME);
end
function[] = tooManyRowsError(obj, nRows, header)
id = sprintf('%s:tooManyRows', header);
ME = MException(id, ['The "direct" metric option is only allowed for priors ',...
    'with a single state vector row. However, the prior for %s has %.f rows.'],...
    obj.name, nRows);
throwAsCaller(ME);
end