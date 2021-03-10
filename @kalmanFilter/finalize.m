function[kf] = finalize(kf)
%% Checks that a Kalman Filter has all essential fields and fills in any
% singleton whichArgs
%
% kf = kf.finalize
% 
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

% Check essential inputs, set whichPrior
assert(~isempty(kf.X), 'You must provide a prior before you run a Kalman Filter');
kf = finalize@ensembleFilter(kf, 'run a Kalman Filter');

% Fill in other whichArgs
args = ["whichFactor", "whichLoc", "whichCov"];
use = [kf.inflateCov, kf.localizeCov, kf.setCov|kf.blendCov];
for f = 1:numel(args)
    if use(f) && isempty( kf.(args(f)) )
        kf.(args(f)) = ones(kf.nTime, 1);
    end
end

end