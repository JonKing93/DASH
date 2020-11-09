function[whichCov, nCov] = checkCovariance(kf, C, Ycov, whichCov)
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
% ----- Outputs -----
%
% whichCov: Which covariance to use in each time step
%
% nCov: The number of covariances

% Error check the state vector covariance
[nState, nSite, nCov] = kf.checkInput(C, 'C');
kf.checkSize(nState, 1, 1, 'C');
kf.checkSize(nSite, 2, 2, 'C');

% Error check the Y covariance
[nSite, nSite2, nCov2] = kf.checkInput(Ycov, 'Ycov');
kf.checkSize(nSite, 2, 1, 'Ycov');
kf.checkSize(nSite2, 2, 2, 'Ycov');
if nCov ~= nCov2
    covSizeError(nCov, nCov2);
end

% Check that each Y covariance is symmetric
for c = 1:nCov
    assert( issymmetric(Ycov(:,:,c)), sprintf(['Y covariance %.f is not a', ...
    'symmetric matrix.'], c));
end

% Defaults and error check for whichCov
isvar = exist('whichCov', 'var') && ~isempty(whichCov);
if ~isvar && nCov==1
    whichCov = ones(1, kf.nTime);
elseif ~isvar && nCov==kf.nTime
    whichCov = 1:kf.nTime;
elseif ~isvar
    error(['The number of covariances (%.f) does not match the number of ',...
        'time steps (%.f), so you must use the "whichCov" input to specify ',...
        'which covariance to use in each time step.'], nCov, kf.nTime);
end
dash.assertVectorTypeN(whichCov, 'numeric', kf.nTime, 'whichCov');
dash.checkIndices(whichCov, 'whichCov', nCov, 'the number of covariances');

end