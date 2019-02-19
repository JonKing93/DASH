function[X] = npdft_static( Xd, Xt, R, rXs, normS )
%% Performs N-pdft for static data assimilation.
% Applies N-pdft using prescribed iteration values.
%
% X = npdft_static( Xd, R, rXs, Xt, normS )
%
% ----- Inputs -----
%
% Xd: Values to be bias corrected.
%
% R: Rotation matrices for each iteration
%
% rXs: Rotated source data for each iteration
%
% Xt: The target dataset
%
% normS: The normalization used to process the source data.
%
% ----- Outputs -----
%
% X: The bias-corrected data.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the number of iterations and channels
[~, N, nIter] = size(rXs);

% Standardize Xd relative to Xs
Xd = (Xd - normS(1,:)) ./ normS(2,:);

% Standardize the observations
[Xt, meanT, stdT] = zscore(Xt);

% For each iteration
for j = 1:nIter
    
    % Apply the appropriate rotation matrix
    rXd = Xd * R(:,:,j);
    rXt = Xt * R(:,:,j);
    
    % For each rotated channel
    for k = 1:N
        
        % Get the tau value of the rotated source data
        tau = getTau( rXs(:,k,j) );
        
        % Use linear interpolation to get the tau values of the current
        % ensemble
        tau = interp1( rXs(:,k,j), tau, rXd(:,k) ); 
        
        % Do the quantile mapping against the observations
        rXd(:,k) = quantile( rXt(:,k), tau ); 
    end
    
    % Apply the inverse rotation
    Xd = rXd / R(:,:,j);
end

% Restore mean and standard deviation from the observations
X = Xd .* stdT + meanT;

end   