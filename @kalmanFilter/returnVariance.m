function[kf] = returnVariance(kf, tf)
%% Specify whether to return the variance of a posterior ensemble. Default
% is to return the variance.
%
% kf = kf.returnVariance(tf)
%
% ----- Input -----
%
% tf: A scalar logical that indicates whether to return the variance of the
%    posterior ensemble (true -- default) or not (false)
%
% ----- Outputs -----
%
% kf: The updated kalman filter object

% Error check
dash.assertScalarType(tf, 'tf', 'logical', 'logical');

% Check for an existing variance calculation
[hasvariance, k] = ismember(posteriorVariance.outputName, kf.Qname);

% If returning variance and it doesn't exist, add to the calculation array
if tf && ~hasvariance
    kf.Q{end+1,1} = posteriorVariance;
    kf.Qname(end+1,1) = posteriorVariance.outputName;
    
% If removing variance and it exists, delete from the calculation array
elseif ~tf && hasvariance
    kf.Q(k) = [];
    kf.Qname(k) = [];
end

end