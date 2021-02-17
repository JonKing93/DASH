function[obj] = metric(obj, type, varargin)
%% Specify a test metric for the optimal sensor test
%
% obj = obj.metric('mean', weights, rows)
% Use a weighted average for the test metric
%
% ----- Inputs -----
%
% weights: A numeric vector containing weights for a metric that consists
%    of a weighted mean. Must either have one element per state vector
%    element, or one element per specified row.
%
% rows: A vectors indicating the rows to use when calculating the index.
%    Either a logical vector the length of the tstate vector, or a set of
%    linear indices.
%
% ----- Outputs -----
%
% obj: The updated optimal sensor object

% Error check the type
dash.assertStrFlag(type, 'The first input');
allowedTypes = "mean";
assert(any(strcmpi(type, allowedTypes)), sprintf(['The first index must be a ',...
    'recognized type of metric. Recognized types are: %s.'], dash.messageList(allowedTypes)));

% Save the arguments for the metric
if strcmpi(type, 'mean')
    obj.metricType = "mean";
    assert(numel(varargin)<=2, 'Metrics of type "mean" can have no more than 2 additional arguments (weights and rows)');
    obj = obj.saveMeanArgs(varargin{:});
end

end
    