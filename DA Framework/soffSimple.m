function[A] = soffSimple(M, D, R, H, sTime, obSets, sObs)
% Implements ensrf updates for a static ensemble with INSTANTANEOUS obs.
%
% A = soffSimple(M, D, R, H, sTime, obSets, sObs)
%
%
% ----- Inputs -----
%
% M: The static model ensemble. (nState x nRun x nTime)
%
% D: The set of observations. (nObs x nTime)
%
% R: The observation uncertainty variance. (nObs x nTime)
%
% H: The sampling matrix. (nObs x nState)
%
% sTime: The season of each time step. (nTime x 1)
%
% obSets: The list of observational sets (nSets x nInstSeas)
%
% sObs: The season that each observation records (nObs x 1)
%
%
% ----- Outputs -----
%
% A: The updated states through time.
%
%
% ----- Written By -----
%
% Jonathan King, 2018, University of Arizona

% Get some sizes 
nState = size(M,1);   % Length of the state vector
nRun = size(M,2);     % Number of model simulations
nTime = size(M,3);    % Number of time steps

% Get the size of the ensemble. This will be the number of model
% simulations multiplied by the (max) number of time states in each season.
[~,maxSeas] = mode(sTime);
nEns = nRun * maxSeas;

% Preallocate the output
A = NaN( nState, nEns, nTime );

% Get the number of observational sets
nSets = size(obSets,1);

% Determine which seasons have observations
hasObs = find( sum(obSets)>0 );

% For each set of seasonal observations...
for s = 1:nSets
    
    % Get the season
    season = hasObs(s);
    
    % Get the indices of time steps for the season
    currSeason = find( (sTime == season) );
    nTimeS = length(currSeason);
    
    % Get the static ensemble for just the season
    nEnsS = nRun * nTimeS;
    Mseas = reshape( M(:,:,currSeason), [nState, nEnsS]);
    
    % Do the static part of the Kalman Updates
    [Mcell, Ycell, Knum] = kalmanSetup( Mseas, H(sObs==season,:) );
    
    % For each time step that is during the desired season...
    for k = 1:nTimeS
        
        % Get the time index
        tdex = currSeason(k);
        
        % Do the Kalman update
        A(:,1:nEnsS,tdex) = ensrfUpdate( D(:,tdex), R(:,tdex), Mcell, Ycell, Knum );
    end
end

end