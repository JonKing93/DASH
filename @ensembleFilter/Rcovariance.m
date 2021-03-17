function[Rcov] = Rcovariance(obj, t)
%% Returns the R covariance used by a filter in a particular time step.
%
% Rcov = obj.covarianceEstimate(t)
%
% ----- Inputs -----
%
% t: The index of an assimilated time step. A scalar positive integer.
%
% ----- Outputs -----
%
% Rcov: The R covariance matrix

% Error check
assert(~isempty(obj.R), 'You have not yet specified R uncertainties');
dash.assertScalarType(t, 't', 'numeric', 'numeric');
t = dash.checkIndices(t, 't', obj.nTime, 'number of time steps');

% Empty whichR
if isempty(obj.whichR)
    obj.whichR = ones(obj.nTime, 1);
end

% Get the sites for the time step and the associated R 
s = ~isnan(kf.Y(:,t));
c = obj.whichR(t);

% Get the covariance matrix
if ~obj.Rcov
    Rcov = diag(obj.R(s, c));
else
    Rcov = obj.R(s, s, c);
end

end