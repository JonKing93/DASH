function[] = checkMissingR

% R covariances
if obj.Rcov
    whichRcov = obj.whichRcov;
    if isempty(whichRcov)
        whichRcov = ones(obj.nTime,1);
    end
    
    % Check for missing covariance
    for t = 1:obj.nTime
        missing = isnan(obj.Y(:,t));
        r = whichRcov(t);
        
        Rt = obj.R(~missing, ~missing, r);
        [row, col] = find(isnan(Rt), 1);
        assert(isempty(row), sprintf('You must specify an R covariance between sites %.f and %.f in time step %.f', row, col, t));
    end
    
% R variances
elseif ~isempty(obj.R)
    missing = isnan(obj.Y) & isnan(obj.(R));
    [row, col] = find(missing, 1);
    assert(isempty(row), sprintf('You must provide an R variance for site %.f in time step %.f', row, col));
end

end