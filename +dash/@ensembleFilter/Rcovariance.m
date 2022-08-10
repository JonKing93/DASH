function[Rcov] = Rcovariance(obj, t, s)
%% dash.ensembleFilter.Rcovariance  Returns R uncertainty covariance for a time steps and sites
% ----------
%   Rcov = <strong>obj.Rcovariance</strong>(t)
%   Returns the R covariance matrix for the queried time steps. If the filter
%   has saved R variances, builds a diagonal covariance matrix from the
%   variances.
%
%   Rcov = <strong>obj.Rcovariance</strong>(t, s)
%   Returns the R covariance matrix at the queried time steps and
%   observation sites. Only includes covariance elements for the requested
%   sites.
% ----------
%   Inputs:
%       t (vector, linear indices [nTime]): The indices of time steps for a filter 
%       s (vector, linear indices [nSite]): The indices of observation sites for a filter
%
%   Outputs:
%       Rcov (numeric 3D array, [nSite x nSite x nTime]): The covariance
%           matrices for the requested sites in the requested time steps.
%           Each element along the third dimension is a symmetric
%           covariance matrix for a particular time step.
%
% <a href="matlab:dash.doc('dash.ensembleFilter.Rcovariance')">Documentation Page</a>

% Fill whichR for static uncertainties. Get index of uncertainties for each
% queried time step
if isempty(obj.whichR)
    obj.whichR = ones(obj.nTime, 1);
end
c = obj.whichR(t);

% Preallocate if builing covariance matrices from variances
if obj.Rtype==0
    nSite = numel(s);
    nTime = numel(t);
    Rcov = NaN(nSite, nSite, nTime);

    % Build covariance from variance
    for k = 1:nTime
        Rvar = obj.R(s, c(k));
        Rcov(:,:,k) = diag(Rvar);
    end

% Otherwise, load covariance directly
else
    Rcov = obj.R(s, s, c);
end

end