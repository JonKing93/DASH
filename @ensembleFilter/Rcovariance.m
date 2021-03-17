function[Rcov] = Rcovariance(obj, t, s)
%% Returns the R covariance used by a filter in a particular time step.
%
% Rcov = obj.Rcovariance(t)
% Return the R covariance matrix for a queried time step.
%
% Rcov = obj.Rcovariance(t, s)
% Return the R covariance for specific sites.
%
% ----- Inputs -----
%
% t: The index of an assimilated time step. A scalar positive integer.
%
% s: The indices of observation sites. Either a vector of positive
%    integers, or a logical vector with one element per site.
%
% ----- Outputs -----
%
% Rcov: The R covariance matrix

% Error check
assert(~isempty(obj.R), 'You have not yet specified R uncertainties');
dash.assertScalarType(t, 't', 'numeric', 'numeric');
t = dash.checkIndices(t, 't', obj.nTime, 'number of time steps');

% Default and error check sites
if ~exist('s','var') || isempty(s)
    s = ~isnan(obj.Y(:,t));
end
s = dash.checkIndices(s, 's', obj.nSite, 'number of observation sites');

% Empty whichR
if isempty(obj.whichR)
    obj.whichR = ones(obj.nTime, 1);
end

% Get the covariance matrix
c = obj.whichR(t);
if ~obj.Rcov
    Rcov = diag(obj.R(s, c));
else
    Rcov = obj.R(s, s, c);
end

end