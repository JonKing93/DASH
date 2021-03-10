function[] = checkMissingR(obj)

% R covariances
if obj.Rcov
    whichRcov = obj.whichRcov;
    if isempty(whichRcov)
        whichRcov = ones(obj.nTime,1);
    end
    
    % Check for missing covariance
    for c = 1:obj.nRcov
        time = find(whichRcov==c);
        [site1, site2] = find( isnan(obj.R(:,:,c)) );
        for k = 1:numel(time)
            t = time(k);
            missing = find( ~isnan(obj.Y(site1,t)) & ~isnan(obj.Y(site2,t)), 1 );
            assert(isempty(missing), sprintf('You must specify an R covariance between site %.f and site %.f in time step %.f', site1(missing), site2(missing), t));
        end
    end
    
% R variances
elseif ~isempty(obj.R)
    missing = isnan(obj.Y) & isnan(obj.(R));
    [row, col] = find(missing, 1);
    assert(isempty(row), sprintf('You must provide an R variance for site %.f in time step %.f', row, col));
end

end