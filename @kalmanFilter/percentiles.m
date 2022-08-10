function[varargout] = percentiles(obj, percentages)
%% kalmanFilter.percentiles  Indicate whether to return ensemble percentiles when running a Kalman Filter
% ----------
%   obj = <strong>obj.percentiles</strong>(percentages)
%   Indicates that the Kalman filter should return the specified
%   percentiles of the posterior ensemble. Overwrites any previously
%   specified percentiles. When using the kalmanFilter.run command, the
%   output structure will include ensemble percentiles in a field named
%   "Aperc".
%
%   Calculating posterior percentiles can be an effective way to evaluate
%   the distribution of a posterior ensemble and evaluate reconstruction
%   uncertainty. Notably, returning a few percentiles often requires much
%   less memory than saving and returning the (often very large) full
%   posterior ensemble. Note that calculating posterior percentiles
%   requires the Kalman filter to update the ensemble deviations. This
%   incurs a higher computational cost than just updating the ensemble
%   mean, so exploratory efforts that only require the updated ensemble
%   mean may wish to refrain from calculating posterior percentiles.
%
%   percentages = <strong>obj.percentiles</strong>
%   Returns the current percentile percentages for the Kalman filter object.
%
%   obj = <strong>obj.percentiles</strong>('reset')
%   Resets the ensemble percentiles for the Kalman filter. The Kalman
%   filter will no longer compute ensemble percentiles, and the output of
%   the kalmanFilter.run command will not include the Aperc field.
% ----------
%   Inputs:
%       percentages (numeric vector): A vector listing the percentages for
%           which to calculate posterior percentiles. Each element should
%           be on the interval 0 <= percentile <= 100
%
%   Outputs:
%       obj (scalar kalmanFilter object): The Kalman filter object with
%           updated percentile preferences
%       percentages (numeric vector | []): The percentages for which
%           ensemble percentiles will be calculated. If there are no
%           percentiles, returns an empty array.
%
% <a href="matlab:dash.doc('kalmanFilter.percentiles')">Documentation Page</a>

%%%%% Parameter: Calculator name
name = "Aperc";
%%%%%

% Setup
header = "DASH:kalmanFilter:percentiles";
dash.assert.scalarObj(obj, header);

% Check for an existing percentiles calculator
[hasCalculator, k] = ismember(name, obj.calculationNames);

% Return status
if ~exist('percentages','var')
    percentages = [];
    if hasCalculator
        percentages = obj.calculations{k}.percentages;
    end
    varargout = {percentages};
    return

% Reset
elseif dash.is.strflag(percentages) && strcmpi(percentages, 'reset')
    if hasCalculator
        obj.calculations(k,:) = [];
        obj.calculationNames(k,:) = [];
        obj.calculationTypes(k,:) = [];
    end
    varargout = {obj};

% Set percentiles. Don't allow empty
else
    if isempty(percentages)
        emptyPercentagesError(obj, header);
    end

    % Error check percentiles
    dash.assert.vectorTypeN(percentages, 'numeric', [], 'percentages', header);
    dash.assert.defined(percentages, 1, 'percentages', header);
    if any(percentages<0) || any(percentages>100)
        invalidPercentagesError(percentages, header);
    end

    % Overwrite or create new calculator
    calculator = dash.posteriorCalculation.percentiles(percentages);
    if hasCalculator
        obj.calculations{k} = calculator;
    else
        obj.calculations{end+1,1} = calculator;
        obj.calculationNames(end+1,1) = name;
        obj.calculationTypes(end+1,1) = 1;
    end
    varargout = {obj};
end

end

% Error messages
function[] = emptyPercentagesError(obj, header)
id = sprintf('%s:emptyPercentages', header);
ME = MException(id, 'The percentages for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = invalidPercentagesError(percentages, header)
bad = find(percentages<0 | percentages>100, 1);
id = sprintf('%s:invalidPercentages', header);
ME = MException(id, ['Percentages must be on the interval 0 <= p <= 100. ',...
    'However, percentage %.f is not on this interval.'], bad);
throwAsCaller(ME);
end