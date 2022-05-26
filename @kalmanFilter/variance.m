function[varargout] = variance(obj, returnVariance)
%% kalmanFilter.variance  Indicate whether to return posterior variance when running a Kalman Filter
% ----------
%   obj = obj.variance(returnVariance)
%   obj = obj.variance("return"|"r"|true)
%   obj = obj.variance("discard"|"d"|false)
%   Indicate whether to return the variance of the posterior ensemble when
%   running a Kalman Filter. If "return"|"r"|true, the output of the
%   kalmanFilter.run command will include the variance of the posterior
%   ensemble. This output will be in a field named "Avar". If you select
%   "discard"|"d"|false, the kalmanFilter.run commnad will not calculate
%   the posterior variance, and its output structure will not include the
%   Avar field. By default, Kalman filter objects do not return the ensemble
%   variance.
%
%   Calculating posterior variance can be an effective way to evaluate to
%   evaluate reconstruction uncertainty, without needing to save and return
%   the (often very large) full posterior ensemble. Note that calculating
%   posterior variance requires the Kalman filter to update the ensemble
%   deviations. This incurs a higher computational cost than just updating
%   the ensemble mean, so exploratory efforts that only require the updated
%   ensemble mean may wish to refrain from calculating posterior variance.
%
%   returnVariance = obj.variance
%   Returns true if the current Kalman filter object will return ensemble
%   variance. Otherwise, returns false.
% ----------
%   Inputs:
%       returnVariance (string scalar | scalar logical): Indicates whether
%           to calculate posterior variance when running a Kalman filter
%           ["return"|"r"|true]: Returns the posterior variance in a field named Avar
%           ["discard"|"d"|false (default)]: Does not calculate posterior variance.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The Kalman filter object with
%           updated variance preferences
%       returnVariance (scalar logical): True if the Kalman filter object
%           will return posterior variance. Otherwise, false.
%
% <a href="matlab:dash.doc('kalmanFilter.variance')">Documentation Page</a>

%%%%% Parameter: Calculator name
name = "Avar";
%%%%%

% Setup
header = "DASH:kalmanFilter:variance";
dash.assert.scalarObj(obj, header);

% Check for an existing variance calculation
[hasCalculator, k] = ismember(name, obj.calculationNames);

% Return current status
if ~exist('returnVariance','var')
    varargout = {hasCalculator};
    return
end

% Parse the variance option
switches = {["d","discard"], ["r","return"]};
returnVariance = dash.parse.switches(returnVariance, switches, 1, 'recognized option', header);

% If returning variance, ensure there is a calculation object
if returnVariance && ~hasCalculator
    obj.calculations{end+1,1} = dash.posteriorCalculation.variance;
    obj.calculationNames(end+1,1) = name;
    obj.calculationTypes(end+1,1) = 0;

% If removing an existing variance, delete from the calculation array
elseif ~returnVariance && hasCalculator
    obj.calculations(k,:) = [];
    obj.calculationNames(k,:) = [];
    obj.calculationTypes(k,:) = [];
end
varargout = {obj};

end