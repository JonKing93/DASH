function[X] = npdft_static( Xd, R, rXs, Xo, normS )

% Get the number of iterations and channels
[~, N, nIter] = size(rXs);

% Standardize Xd relative to Xs
Xd = (Xd - normS(1)) / normS(2);

% Get the observation standardization
[~, meanT, stdT] = zscore(Xo);

% For each iteration
for j = 1:nIter
    
    % Apply the appropriate rotation matrix
    rXd = Xd * R(:,:,j);
    
    % For each rotated channel
    for k = 1:N
        
        % Get the tau value of the rotated source data
        tau = getTau( rXs(:,k,j) );
        
        % Use linear interpolation to get the tau values of the current
        % ensemble
        tau = interp1( rXs(:,k,j), tau, rXd(:,k) ); 
        
        % Do the quantile mapping against the observations
        rXd(:,k) = quantile( Xo, tau ); 
    end
    
    % Apply the inverse rotation
    Xd = rXd / R(:,:,j);
end

% Restore mean and standard deviation from the target
X = Xd .* stdT + meanT;

end   