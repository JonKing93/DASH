function[varargout] = blend(obj, C, Ycov, weight, whichBlend)
%% kalmanFilter.blend  Blends ensemble covariance with a climatological covariance
% ----------
%   obj = obj.blend(C, Ycov)
%   Blends the ensemble covariance with a climatological covariance using a
%   weighting of 50% of each covariance. When covariance is blended, the
%   Kalman filter first calculates the usual covariance between the
%   ensemble and the observation estimates. Next, the filter computes the
%   weighted sum of this ensemble covariance and a fixed climatological
%   covariance. The weighted sum of the two covariances is then used to
%   update the ensemble. This technique is often used with offline evolving
%   priors: the resulting covariance reflects both the evolving covariance
%   from the ensemble, while the climatological covariance can help reduce
%   sampling errors for small ensembles. Blending is applied after
%   inflation and localization are applied to the ensemble covariance.
%   Neither inflation nor localization are applied to the climatological
%   covariance.
%
%   The first input provides the climatological covariance between the
%   state vector elements and the observation sites. It should be a 3D
%   array with one row per state vector element, and one column per
%   observation site. The second input provides the climatological
%   covariance between the observation sites and one another. It should be
%   a 3D array with one row and one column per observation site. Each
%   element along the third dimension of Ycov must be a symmetric matrix.
%
%   The two inputs must have the same number of elements along the third
%   dimension. If the third dimension has one element (i.e. both inputs are
%   matrices), then blends the same climatological covariances in all time
%   steps.  Otherwise, the third dimension must have one element per time step
%   (although see the thrid syntax for relaxing this requirement). C may
%   contain NaN elements, although the filter will return a NaN update at
%   any state vector rows with a NaN covariance. Ycov cannot include NaN
%   elements.
%
%   obj = obj.blend(C, Ycov, weight)
%   Specify the blending weight to use for each climatological covariance.
%   By default, uses a blending weight of 0.5. The blending weight for the
%   ensemble covariance is calculated as 1 - weight. Blending weights must
%   be on the interval 0 < weight < 1. If you provide a single weight, uses
%   the same weight for each set of covariances. Otherwise, the number of
%   weights must match the number of sets of covariances.
%
%   obj = obj.blend(C, Ycov, weight, whichBlend)
%   Indicate which set of climatological covariances to use in each time
%   step. This syntax allows the number of climatological covariances to
%   differ from the number of assimilation time steps.
%
%   [C, Ycov, weight, whichBlend] = obj.blend
%   Returns the current climatological covariances and blending weights for
%   the Kalman Filter.
%
%   obj = obj.blend('reset')
%   Deletes any existing climatological covariances and blending weights
%   from the Kalman filter.
% ----------
%   Inputs:
%       C (numeric 3D array [nState x nSite x 1|nTime|nLoc]): The
%           climatological covariance between the state vector elements and
%           observation sites. If using a single set of covariances, should
%           have a single element along the third dimension. If the number
%           of elements along the third dimension matches the number of
%           time steps, uses the indicated set of covariances in each time
%           step. If the number of elements is neither 1 nor the number of
%           time steps, use the whichBlend input to indicate which
%           climatological covariance to use in each time step. May include
%           NaN values, but the filter will return a NaN update for state
%           vector elements with NaN covariances.
%       Ycov (numeric 3D array [nSite x nSite x 1|nTime|nLoc]): The
%           climatological covariance between the observation sites and one
%           another. A 3D array with one site and one column per
%           observation site. The number of elements along the third
%           dimension must match the number of elements for the C
%           input. Cannot include NaN values. Each element along the third
%           dimension must be a symmetric matrix and the diagonal elements
%           of these matrices must all be positive.
%       weight (numeric vector [1 | nLoc]): The blending weight to use for
%           the climatological covariance. Must be on the interval 
%           0 < weight < 1. The blending weight for the ensemble covariance
%           is calculated as 1 - weight. If you provide a single weight,
%           uses the same blending weight for all covariances. Otherwise,
%           must have one element per covariance. By default, the blending
%           weight is set to 0.5.
%       whichBlend (vector, linear indices [nTime]): Indicates which set of
%           covariances to blend in each time step. Must have one element
%           per assimilation time step. Each element is the index of one of
%           the sets of climatological covariances.
%
%   Outputs:
%       obj (scalar kalmanFilter object): The kalmanFilter object with
%           updated blending options
%       C (numeric 3D array [nState x nSite x 1|nTime|nBlend] | []): The
%           current blending covariances between the state vector
%           elements and observation site for the filter. If blending has
%           not been implemented, returns an empty array.
%       Ycov (numeric 3D array [nSite x nSite x 1|nTime|nLoc] | []): The
%           current blending covariances between the observation sites and
%           each other for the filter. If blending has not been
%           implemented, returns an empty array.
%       weight (numeric vector [nLoc] | []): The current blending weight for
%           each climatological covariance. If blending has not been
%           implemented, returns an empty array.
%       whichBlend (vector, linear indices [nTime] | []): Indicates which
%           set of covariances will be blended in each time step. If there
%           is a single set of covariances, returns an empty array.
%
% <a href="matlab:dash.doc('kalmanFilter.blend')">Documentation Page</a>

% Setup
try
    header = "DASH:kalmanFilter:blend";
    dash.assert.scalarObj(obj, header);
    
    % Return
    if ~exist('C','var')
        varargout = {obj.Cblend, obj.Yblend, obj.blendingWeights(:,1), obj.whichBlend};

    % Delete
    elseif dash.is.strflag(C) && strcmpi(C, 'reset')
        if exist('Ycov','var')
            dash.error.tooManyInputs;
        end

        % Delete and reset time
        obj.Cblend = [];
        obj.Yblend = [];
        obj.blendingWeights = [];
        obj.whichBlend = [];
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior) ...
                && isempty(obj.whichInflate) && isempty(obj.whichLoc) && isempty(obj.whichSet)
            obj.nTime = 0;
        end
        varargout = {obj};

    % Set. Get default
    else
        if ~exist('whichBlend','var') || isempty(whichBlend)
            whichBlend = [];
        end

        % Don't allow empty. Also don't allow if covariance is set
        if isempty(C)
            emptyBlendError(obj, header);
        elseif ~isempty(obj.Cset)
            covarianceSetError(obj, header);
        end

        % Optionally set sizes
        [nRows, nCols, nBlend] = size(C, 1:3);
        if isempty(obj.X) && isempty(obj.wloc)
            obj.nState = nRows;
        end
        if isempty(obj.Y) && isempty(obj.Ye) && isempty(obj.R) && isempty(obj.wloc)
            obj.nSite = nCols;
        end

        % Initial error check
        siz = [obj.nState, obj.nSite, nBlend];
        dash.assert.blockTypeSize(C, ["single","double"], siz, 'C', header);
        dash.assert.defined(C, 2, 'C', header);

        siz = [obj.nSite, obj.nSite, nBlend];
        dash.assert.blockTypeSize(Ycov, ["single","double"], siz, 'Ycov', header);
        dash.assert.defined(Ycov, 1, 'Ycov', header);
        dash.assert.covariances(Ycov, 'Ycov', header);

        % Default and check weights
        if ~exist('weight','var')
            weight = 0.5;
        end
        if isscalar(weight)
            weight = repmat(weight, nBlend, 1);
        end
        dash.assert.vectorTypeN(weight, 'numeric', nBlend, 'weight', header);
        if any(weight<=0) || any(weight>=1)
            invalidWeightError(weight, header);
        end
        weight = weight(:);

        % Note whether allowed to set time
        timeIsSet = true;
        if isempty(obj.Y) && isempty(obj.whichR) && isempty(obj.whichPrior) ...
                && isempty(obj.whichFactor) && isempty(obj.whichLoc)
            timeIsSet = false;
        end

        % Error check and process whichBlend
        obj = obj.processWhich(whichBlend, 'whichBlend', nBlend, 'sets of blending covariances',...
                                                timeIsSet, false, header);

        % Save and build output
        obj.Cblend = C;
        obj.Yblend = Ycov;
        obj.blendingWeights = [weight, 1-weight];
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
function[] = emptyBlendError(obj, header)
id = sprintf('%s:emptyBlend', header);
ME = MException(id, 'The climatological covariance for %s cannot be empty.', obj.name);
throwAsCaller(ME);
end
function[] = covarianceSetError(obj, header)
id = sprintf('%s:covarianceAlreadySet', header);
ME = MException(id, ['You cannot implement covariance blending for %s because ',...
    'you already provided a user-specified covariance matrix.'], obj.name);
throwAsCaller(ME);
end
function[] = invalidWeightError(weight, header)
bad = find(weight<=0 | weight>=1, 1);
if numel(weight) == 1
    name = 'the blending weight';
else
    name = sprintf('blending weight %.f', bad);
end
id = sprintf('%s:invalidBlendingWeight', header);
ME = MException(id, ['Blending weights must be on the interval 0 < weight < 1',...
    'but %s is not on this interval'], name);
throwAsCaller(ME);
end





