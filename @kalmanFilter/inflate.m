function[kf] = inflate(kf, inflateFactor, whichFactor)
%% Specify an inflation factor.
%
% kf = kf.inflate( factor )
% Specifies a multiplicative covariance inflation factor.
%
% kf = kf.inflate(factors, whichFactor)
% Specifies different inflation factors in different time steps.
%
% ----- Inputs -----
%
% factors: A numeric vector of values greater than 1.
%
% whichFactor: A vector with one element per time step. Each element is the
%    index of the inflation factor to use for that time step.
%
% ----- Outputs -----
%
% kf: The updated kalman filter object

% Only provide inflation after the prior and observations are set
kf.assertEditableCovariance('covariance inflation options');

% Default for whichFactor
if ~exist('whichFactor','var') || isempty(whichFactor)
    whichFactor = [];
end

% Error check the inflation factors
dash.assertVectorTypeN(factor, 'numeric', [], 'factor');
dash.assertRealDefined(factor, 'factor');
assert(all(factor>=1), 'inflation factors cannot be smaller than 1.');

% If there is a single factor, cannot use whichFactor
nFactor = numel(factor);
if nFactor==1 && ~isempty(whichFactor)
    error(['You have provided a single inflation factor, so you cannot use ',...
        'the second input (whichFactor) to specify time steps.']);

% Otherwise, default and error check whichFactor
elseif nFactor>1
    if isempty(whichFactor) && nFactor==kf.nTime
        whichFactor = 1:kf.nTime;
    elseif isempty(whichFactor)
        error(['The number of inflation factors (%.f) does not match the number ',...
            'of time steps (%.f), so you must use the second input (whichFactor) ',...
            'to specify which factor to use in each time step.'], nFactor, kf.nTime);
    end
    dash.assertVectorTypeN(whichFactor, 'numeric', kf.nTime, 'whichFactor');
    dash.checkIndices(whichFactor, 'whichFactor', nFactor, 'the number of inflation factors');
end

% Save
kf.inflateFactor = factor;
kf.inflateCov = true;
kf.whichFactor = whichFactor;

end