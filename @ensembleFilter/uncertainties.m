function[obj] = uncertainties(obj, R, isCov, whichCov)
%
% obj.uncertainties(Rvar)
% 
% obj.uncertainties(Rcov, isCov)
%
% obj.uncertainties(Rcov, isCov, whichCov)

% Require observations
assert(~isempty(obj.Y), 'You must provide observations before you specify observation uncertainties');

% Default and error check isCov
if ~exist('isCov','var') || isempty(isCov)
    isCov = false;
end
dash.assertScalarType(isCov, 'isCov', 'logical', 'logical');

% Default whichCov
if isCov && (~exist('whichCov','var') || isempty(whichCov))
    whichCov = [];
end

% R variances
if ~isCov
    assert(isempty(whichCov), 'You cannot use the whichCov argument when specifying R variances');
    [nSite, nTime] = obj.checkInput(R, 'Rvar', true, true);
    assert(~any(R(:)<=0), 'R variances must be greater than 0.');
    
    % Size conflicts
    assert(nSite==obj.nSite || nSite==1, sprintf('You previously specified observations for %.f sites, but Rvar has %.f sites', obj.nSite, nSite));
    assert(nTime==obj.nTime || nTime==1, sprintf('You previously specified observations for %.f time steps, but Rvar has %.f time steps', obj.nTime, nTime));
    
    % Propagate
    if nSite==1
        R = repmat(R, [obj.nSite, 1]);
    end
    if nTime==1
        R = repmat(R, [1, obj.nTime]);
    end
    
% R covariances
else
    [nSite1, nSite2, nCov] = obj.checkInput(R, 'Rcov', true, false);
    
    % Size conflicts
    assert(nSite1==obj.nSite, sprintf('You previously specified observations for %.f sites, but Rcov has %.f sites (rows)', obj.nSite, nSite1));
    assert(nSite1==nSite2, sprintf('The number of rows in Rcov (%.f) does not match the number of columns (%.f)', nSite1, nSite2));

    % Parse whichCov
    whichCov = obj.parseWhich(whichCov, 'whichCov', nCov, 'R covariance');
    
    % Error check each covariance matrix
    for c = 1:nCov
        Rc = R(:,:,c);
        Rc(isnan(Rc)) = 1;
        assert(issymmetric(Rc), sprintf('R covariance %.f is not a symmetric matrix', c));
        assert( ~any(diag(Rc)<=0), sprintf('The diagonal elements of R covariance %.f must be greater than 0', c));
    end
end

% Save values
obj.Rcov = isCov;
obj.R = R;
obj.whichRcov = whichCov;

% Check for missing R values
obj.checkMissingR;

end