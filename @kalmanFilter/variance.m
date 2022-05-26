function[obj] = variance(obj, returnVariance)
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
%   Avar field. By default, Kalman filter object do not return the ensemble
%   variance.
%
%   Calculating the posterior variance requires the Kalman filter to update
%   the ensemble deviations, which incurs a higher computational cost than
%   just updating the ensemble mean. Thus, exploratory efforts that only
%   require the updated ensemble member may wish to refrain from
%   calculating posterior variance. However, the posterior variance is a
%   useful metric for evaluating the uncertainty in a reconstruction, and
%   we recommend calculating variance for non-exploratory efforts.
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
%
% <a href="matlab:dash.doc('kalmanFilter.variance')">Documentation Page</a>

% Setup
header = "DASH:kalmanFilter:variance";
dash.assert.scalarObj(obj, header);

% Parse the variance option
switches = {["d","discard"], ["r","return"]};
returnVariance = dash.parse.switches(returnVariance, switches, 1, 'recognized option', header);

% Check for an existing variance calculation
name = dash.posteriorCalculation.variance.outputName;
[hasCalculator, k] = ismember(name, obj.calculationNames);

% If returning variance, ensure there is a calculation object
if returnVariance && ~hasCalculator
    obj.calculations{end+1,1} = dash.posteriorCalculation.variance;
    obj.calculationNames(end+1,1) = name;

% If removing an existing variance, delete from the calculation array
elseif ~returnVariance && hasCalculator
    obj.calculations(k,:) = [];
    obj.calculationNames(k,:) = [];
end

end