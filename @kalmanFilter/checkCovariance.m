function[whichCov, nCov] = checkCovariance(kf, C, Ycov, whichCov, locInputs)
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
    names = ["w", "yloc", "localization", "whichLoc"];
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

% Defaults and error check for whichCov
isvar = exist('whichCov', 'var') && ~isempty(whichCov);
if ~isvar && nCov==1
    whichCov = ones(1, kf.nTime);
elseif ~isvar && nCov==kf.nTime
    whichCov = 1:kf.nTime;
elseif ~isvar
    missingWhichError(nCov, kf.nTime, names(4), names(3));
end
dash.assertVectorTypeN(whichCov, 'numeric', kf.nTime, names(4));
dash.checkIndices(whichCov, 'whichCov', nCov, sprintf('the number of %ss',type) );
whichCov = whichCov(:)';

end

% Long error messages
function[] = covSizeError(nCov, nCov2, inputName, type)
error(['%s must have %.f elements along dimension 3 (one per %s), but it has ',...
    '%.f elements instead.'], inputName, nCov, type, nCov2);
end
function[] = notSymmetricError(type, c)
error('Y %s %.f is not a symmetric matrix.', type, c);
end
function[] = missingWhichError(nCov, nTime, name, type)
error(['The number of %ss (%.f) does not match the number of time steps ',...
    '(%.f), so you must use the "%s" input to specify which %s ',...
    'to use in each time step.'], type, nCov, nTime, name, type );
end