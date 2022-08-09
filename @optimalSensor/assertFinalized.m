function[] = assertFinalized(obj, actionName, header)
%% optimalSensor.assertFinalized  Throw error if an optimal sensor does not have essential data inputs
% ----------
%   <strong>obj.assertFinalized</strong>
%   Checks that the optimal sensor object has estimates, uncertainties, and
%   a metric. If not, throws an error.
%
%   <strong>obj.assertFinalized</strong>(actionName, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       actionName (string scalar): The name of the action being attempted
%           as a gerund. Default is 'implementing an optimal sensor'
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('optimalSensor.assertFinalized')">Documentation Page</a>

% Defaults
if ~exist('actionName', 'var')
    actionName = 'implementing an optimal sensor';
end
if ~exist('header','var')
    header = "DASH:optimalSensor:assertFinalized";
end

% Metric
try
    if isempty(obj.J)
        id = sprintf('%s:missingMetric', header);
        link = '<a href="matlab:dash.doc(''optimalSensor.metric'')>optimalSensor.metric</a>';
        error(id, ['You must provide a sensor metric (J) before %s. See the ',...
            '%s command for help.'], actionName, link);
    end
    
    % Estimates
    if isempty(obj.Ye)
        id = sprintf('%s:missingEstimates', header);
        link = '<a href="matlab:dash.doc(''optimalSensor.estimates'')>optimalSensor.estimates</a>';
        error(id, ['You must provide estimates (Ye) before %s. See the ',...
            '%s command for help.'], actionName, link);
    end

    % Uncertainties
    if isempty(obj.R)
        id = sprintf('%s:missingUncertainties', header);
        link = '<a href="matlab:dash.doc(''optimalSensor.uncertainties'')>optimalSensor.uncertainties</a>';
        error(id, ['You must provide error uncertainties (R) before %s. See the ',...
            '%s command for help.'], actionName, link);
    end

% Minimize error stack
catch ME
    if startsWith(ME.identifier, 'DASH')
        throwAsCaller(ME);
    else
        rethrow(ME);
    end
end

end