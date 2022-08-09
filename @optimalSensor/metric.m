function[varargout] = metric2(obj, J)
%% optimalSensor.metric  Specify the metric for an optimal sensor
% ----------
%   obj = <strong>obj.metric</strong>(J)
%   Provide the initial sensor metric for optimal sensor algorithms. The
%   metric is a scalar value assessed across an ensemble. The ability of
%   observation sites to reduce the variance of the metric across the
%   ensemble forms the basis of the optimal sensor algorithm. The sensor
%   metric should be a vector with one element per ensemble member and
%   cannot contain NaN values.
%
%   J = <strong>obj.metric</strong>
%   Returns the current metric for the optimal sensor object.
%
%   obj = <strong>obj.metric</strong>('delete')
%   Deletes any current metric from the optimal sensor object.f
% ----------
%   Inputs:
%       J (numeric vector [nMembers]): The initial sensor metric for any
%           optimal sensor algorithms. A numeric vector with one element
%           per ensemble member.
%       
%   Outputs:
%       obj (scalar optimalSensor object): The optimalSensor object with
%           an updated metric
%       J (numeric row vector [1 x nMembers]): The current metric for the
%           optimalSensor object
%
% <a href="matlab:dash.doc('optimalSensor.metric')">Documentation Page</a>

%  Setup
header = "DASH:optimalSensor:metric";
dash.assert.scalarObj(obj, header);

% Return
if ~exist('J','var')
    varargout = {obj.J};

% Delete
elseif dash.is.strflag(J) && strcmpi(J, 'delete')
    obj.J = [];
    if isempty(obj.Ye)
        obj.nMembers = 0;
    end
    varargout = {obj};

% Set metric. Don't allow empty
else
    if isempty(J)
        emptyMetricError(obj, header);
    end

    % Set sizes
    nMembers = numel(J);
    if isempty(obj.Ye)
        obj.nMembers = nMembers;
    end

    % Error check
    dash.assert.vectorTypeN(J, ["single","double"], obj.nMembers, 'J', header);
    dash.assert.defined(J, 1, 'J', header);

    % Set metric
    obj.J = J;
    obj.nMembers = numel(J);
    varargout = {obj};
end

end

%% Error messages
function[] = emptyMetricError(obj, header)
id = sprintf('%s:emptyMetric', header);
ME = MException(id, 'The metric for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
