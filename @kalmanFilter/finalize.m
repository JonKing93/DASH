function[kf] = finalize(kf, actionName)
%% Checks that a Kalman Filter has all essential fields and fills in any
% singleton whichArgs
%
% kf = kf.finalize(actionName)
%
% ----- Inputs -----
%
% actionName: The action that the filter is being finalized for. A string
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Check for essential inputs
assert(~isempty(kf.M), sprintf('You must provide a prior before you %s', actionName));
assert(~isempty(kf.D), sprintf('You must provide observations before you %s', actionName));
assert(~isempty(kf.Y), sprintf('You must provide proxy estimates before you %s.', actionName));

% Fill in empty whichArgs
args = ["whichPrior", "whichFactor", "whichLoc", "whichCov"];
use = [true, kf.inflateCov, kf.localizeCov, kf.setCov|kf.blendCov];
for f = 1:numel(args)
    if use(f) && isempty( kf.(args(f)) )
        kf.(args(f)) = ones(kf.nTime, 1);
    end
end

end