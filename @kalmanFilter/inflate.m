function[varargout] = inflate(obj, factor, whichFactor)
%% kalmanFilter.inflate  Provide inflation factors for a Kalman Filter
% ----------
%   obj = <strong>obj.inflate</strong>(factor)
%   Specifies a multiplicative covariance inflation factor for the Kalman
%   Filter. The covariance term in the Kalman Gain numerator will be
%   multiplied by the inflation factor in order to increase the apparent
%   covariance for the filter. The inflation factor is applied before
%   localization and blending. Inflation is not allowed for user-provided
%   covariance matrices.
% 
%   If factor is scalar, uses the same inflation factor for all time steps.
%   Otherwise, must be a vector with one element per time step (although 
%   see the next syntax for relaxing this requirement).
%
%   obj = <strong>obj.inflate</strong>(factor, whichFactor)
%   Specify which inflation factor to use in each assimilation time step.
%   This syntax allows the number of inflation factors to differ from the
%   number of time steps.
%
%   [factor, whichFactor] = <strong>obj.inflate</strong>
%   Returns the inflation factor for the Kalman filter, and indicates which
%   factor is used in each assimilation time step.
%
%   obj = <strong>obj.inflate</strong>('reset')
%   Deletes any current inflation factors from the Kalman Filter.
% ----------
%   Inputs:
%       factor (numeric vector [1|nTime|nInflate]): The inflation factors
%           to use for the Kalman Filter. All elements must be greater than
%           1. If scalar, uses the same factor for all time steps. If a
%           vector with one element per time step, uses the indicated
%           inflation factor in each time step. If the number of factors is
%           neither 1 nor the number of time steps, use the whichFactor
%           input to indicate which factor to use in each time step.
%       whichFactor (vector, linear indices [nTime]): Indicates which
%           inflation factor to use in each time step. Must have one
%           element per assimilation time step. Each element if the index
%           to one of the input inflation factors.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           updated inflation factor.
%       factor (numeric vector [1|nTime|nInflate] | []): The current inflation
%           factors for the Kalman Filter. If there is no inflation factor,
%           returns an empty array.
%       whichFactor (vector, linear indices [nTime] | []): Indicates which
%           which inflation factor is used in each assimilation time step.
%           If there is a single inflation factor, retruns an empty array.
%
% <a href="matlab:dash.doc('kalmanFilter.inflate')">Documentation Page</a>

% Setup
try
    header = "DASH:kalmanFilter:inflate";
    dash.assert.scalarObj(obj, header);
    
    % Return factor
    if ~exist('factor','var')
        varargout = {obj.inflationFactor, obj.whichFactor};

    % Delete
    elseif dash.is.strflag(factor) && strcmpi(factor, 'reset')
        if exist('whichFactor','var')
            dash.error.tooManyInputs;
        end

        % Delete and reset time
        obj.inflationFactor = [];
        obj.whichFactor = [];
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior) ...
                && isempty(obj.whichLoc) && isempty(obj.whichBlend) && isempty(obj.whichSet)
            obj.nTime = 0;
        end
        varargout = {obj};

    % Set. Get default
    else
        if ~exist('whichFactor','var') || isempty(whichFactor)
            whichFactor = [];
        end

        % Don't allow empty. Also don't allow if covariance is set
        if isempty(factor)
            emptyFactorError(obj, header);
        elseif ~isempty(obj.Cset)
            covarianceSetError(obj, header);
        end

        % Error check
        dash.assert.vectorTypeN(factor, 'numeric', NaN, 'factor', header);
        dash.assert.defined(factor, 1, 'factor', header);
        if any(factor<1)
            smallFactorError(factor, header);
        end

        % Note whether allowed to set time
        timeIsSet = true;
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior) ...
                && isempty(obj.whichLoc) && isempty(obj.whichBlend)
            timeIsSet = false;
        end

        % Error check and process whichFactor
        obj = obj.processWhich(whichFactor, 'whichFactor', numel(factor), ...
                            'inflation factors', timeIsSet, false, header);

        % Save and build output
        obj.inflationFactor = factor(:);
        varargout = {obj};
    end

% Minimize error stack
catch ME
    if startsWith(ME.identifier, "DASH")
        throwAsCaller(ME);
    else
        rethrow(ME);
    end
end

end

% Error messages
function[] = emptyFactorError(obj, header)
id = sprintf('%s:emptyFactor', header);
ME = MException(id, 'The inflation factors for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = covarianceSetError(obj, header)
id = sprintf('%s:covarianceAlreadySet', header);
ME = MException(id, ['You cannot implement an inflation factor for %s because ',...
    'you already provided a user-specified covariance matrix.'], obj.name);
throwAsCaller(ME);
end
function[] = smallFactorError(factor, header)
bad = find(factor<1, 1);
if numel(factor)==1
    name = 'the factor';
else
    name = sprintf('factor %.f', bad);
end
id = sprintf('%s:factorTooSmall', header);
ME = MException(id, ['Inflation factors must be greater than 1, but %s is not ',...
    'greater than 1.'], name);
throwAsCaller(ME);
end