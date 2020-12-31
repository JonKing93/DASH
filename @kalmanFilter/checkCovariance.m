function[whichArg, nCov] = checkCovariance(kf, C, Ycov, whichArg, locInputs)
%% Error checks state vector covariance, Y covariance, and whichCov inputs
% 
% [whichCov, nCov] = kf.checkCovariance(C, Ycov, whichCov)
%
% ----- Inputs -----
%
% C: A state vector covariance input
%
% Ycov: A Y covariance input
%
% whichCov: A whichCov input
%
% locInputs: Scalar logical that indicates whether the inputs are for
%    localization weights. Used to toggle names in error messsages.
%
% ----- Outputs -----
%
% whichCov: Which covariance to use in each time step
%
% nCov: The number of covariances

% Get the error message names
if ~exist('locInputs','var') || isempty(locInputs)
    locInputs = false;
end
names = ["C", "Ycov", "covariance", "whichCov"];
if locInputs
    names = ["wloc", "yloc", "localization", "whichLoc"];
end

% Error check the state vector covariance
[nState, nSite, nCov] = kf.checkInput(C, names(1));
kf.checkSize(nState, 1, 1, names(1));
kf.checkSize(nSite, 2, 2, names(1));

% Error check the Y covariance
[nSite, nSite2, nCov2] = kf.checkInput(Ycov, names(2));
kf.checkSize(nSite, 2, 1, names(2));
kf.checkSize(nSite2, 2, 2, names(2));
if nCov ~= nCov2
    covSizeError(nCov, nCov2, names(2), names(3));
end

% Check that each Y covariance is symmetric
for c = 1:nCov
    if ~issymmetric( Ycov(:,:,c) )
        notSymmetricError(names(3), c);
    end
end

% Parse whichCov or whichLoc
whichArg = kf.parseWhich(whichArg, names(4), nCov, names(3));

end

% Long error messages
function[] = covSizeError(nCov, nCov2, inputName, type)
error(['%s must have %.f elements along dimension 3 (one per %s), but it has ',...
    '%.f elements instead.'], inputName, nCov, type, nCov2);
end
function[] = notSymmetricError(type, c)
error('Y %s %.f is not a symmetric matrix.', type, c);
end