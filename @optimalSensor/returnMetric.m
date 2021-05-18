function[os] = returnMetric(os, fields, returnFields)
%% Return the metric from an optimal sensor test.
%
% os = os.returnMetric
% os = os.returnMetric(true)
% Returns the initial metric, final metric, and updated metric following
% the addition of each new optimal sensor.
%
% os = os.returnMetric(false)
% Disable the metric output.
%
% os = os.returnMetric(fields)
% Specify specific metric fields (initial, final, updated) to include in
% the output.
%
% os = os.returnMetric(fields, returnFields)
% Select whether specific metric fields are returned as output.
%
% ----- Inputs -----
%
% fields: A string or cellstring vector of metric fields.
%   "initial" or "i": The initial metric
%   "updated" or "u": The updated metric following the addition of each new sensor
%   "final" or "f": The final updated metric
%
% returnFields: A scalar logical or logical vector indicating whether to
%    return each listed field in output. If a scalar logical, applies the
%    same option to all listed fields. If a vector, must have one element
%    per listed field.
%
% ----- Output -----
%
% os: The updated optimal sensor object.

% Get the allowed output fields. Parse the no inputs case
outputFields = fieldnames(os.return_metric);
if ~exist('fields','var')
    fields = true;
end

% Logical first input
if islogical(fields)
    assert(isscalar(fields), 'When the first input is a logical, it must be scalar');
    assert( ~exist('returnFields','var') || isempty(returnFields), 'You cannot use the second "returnFields" input unless you specify field names');
    returnFields = fields;
    fields = outputFields;

% String fields
elseif dash.isstrlist(fields)
    fields = string(fields);
    dash.checkStrsInList(fields, outputFields, 'fields', 'allowed output field');
    assert(numel(fields)==numel(unique(fields)), 'fields contains duplicate names');

% Anything else
else
    error('The first input must be a scalar logical, string vector, cellstring vector, or character row vector');
end

% Default returnFields and error check
if ~exist('returnFields','var') || isempty(returnFields)
    returnFields = true;
end
assert(islogical(returnFields), 'returnFields must be logical');

% Get returnFields for each listed field
nFields = numel(fields);
if isscalar(returnFields)
    returnFields = repmat(returnFields, [1 nFields]);
else
    dash.assertVectorTypeN(returnFields, [], nFields, 'returnFields');
end

% Update the output fields
for f = 1:nFields
    name = char(fields(f));
    os.return_metric.(name) = returnFields(f);
end

end