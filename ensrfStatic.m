function[] = ensrfStatic( M, D, R, H, writeArgs )
% This is the driver for a static offline EnSRF approach.
%
% M: A set of model states. Since this is an offline approach, this set of
%    states is static. (N x MC)
%
% D: A set of observations in time. (N x t)
%
% R: Observational error-uncertainties / variances. (N x t)
%
% H: The sampling matrix for the observations.
%
% tSpan: A scalar. Reports the number of time-steps to use for the
% time-averaging update.
%
% writeArgs: A cell of args used for writing to netCDF. The first element
% contains the netCDF filename. The second element is a string containing
% the name of the variable being written.

% Get some sizes
nEns = size(M,2);
nTime = size(D,2);

% Separate model into means and deviations.
Mmean = mean(M,2);
Mdev = M - Mmean;

% Get the values of the model ensemble at the observation sampling sites.
% Split into means and deviations. Also get the variances.
Y = H * M;
Ymean = mean(Y,2);
Ydev = Y - Ymean;
Yvar = var(Y,0,2);

% Get the Kalman Gain numerators (unchanging for different obs, so
% calculate outside of the loop)
unbias = 1 / (nEns-1);
Knum = unbias * Mdev * Ydev';

% For each new timestep...
% !!!!!
% We should be able to parallelize the time loop (but only if not
% time-averaging...)
progressbar(0);
for t = 1:100
    
    % Get the indices of the non-NaN observations
    currentObs = find( ~isnan( D(:,t) ) );
    nObs = length(currentObs);
    

    % Update the ensemble serially. For each observation...
    % !!!!!!!
    % Since we are writing output to file, it would probably be better to
    % parallelize this loop, rather than the time steps. Also, this should
    % conserve better for time-averaging, where time steps may not be
    % independent.
    %
    % Of course, this could be tricky, because the update steps depend on
    % consecutive updates. Probably the best solution would be to calculate
    % the Kalman Gains and scaling factors in parallel, and then do serial
    % updates.
    %
    % If we parallelize here, be sure to pre-slice anything that uses the
    % obsDex index. For example: Dslice = D(currentObs,t), then parfor k =
    % 1:length(currentObs)
    for k = 1:nObs
        
        % Get the index of the observation
        obsDex = currentObs(k);     % Temporary Var
        
        % Get the innovation vector
        innov = D(obsDex,t) - Ymean(obsDex, :);
        
        % Get the Kalman Gain Denominator
        Kdenom = Yvar(obsDex) + R(obsDex,t);
        
        % Get the Kalman Gain
        K = Knum(:,obsDex) ./ Kdenom;
        
        % Update the means
        Amean = Mmean + K*innov;
        
        % Get the ensemble square root filter matrix
        alpha = 1/(1+sqrt( R(obsDex,t) / (Yvar(obsDex)+R(obsDex,t)) ) );
        Kensrf = alpha * K;
        
        % Update the deviations
        Adev = Mdev - Kensrf * Ydev(obsDex,:);
        
        % Add deviations and means for complete update
        A = Amean + Adev;
    end
        
    % !!!!!!!
    % For a general approach, is it appropriate to only be interested in
    % the mean value. Also, if we only care about the mean value, should we
    % still update the deviations? Might be more efficient to do devmean =
    % mean(Adev,2), Atrue = Amean + devmean.
    %
    % Get the mean ensemble as the final output
    A = mean(A,2);
    
    % Reshape state vector to model format
    A = reshape(A, writeArgs{3});
    
    % Write output to NetCDF
    ncwrite( writeArgs{1}, writeArgs{2}, A, [1,1,t] );
    
    % !!!!!!!!!!!!!!!!!
    % Right now, this netcdf function is written for lon x lat x time. It
    % should be made more general to allow other dimensional sizes.
    progressbar(t/100);
end

end