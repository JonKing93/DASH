% Part 2: Prepare the data for seasonalDA

% Set the size of the static ensemble
nRun = 100;

%% Make the static ensemble, M

% Preallocate
nState = size(T,1);
nRun = size(T,2);
M = NaN(nState, nRun);

% Get the number of years
nYears = size(T,3)/12;

% Keep track of which years are recorded
years = repmat( (1:nYears)', [1 nRun] );

% For each member of the static ensemble
for k = 1:nEns
    
    % Choose a random year and ensemble
    ens = ceil( randInterval(0,12,1) );
    y = ceil( randInterval(0,nYears,1) );
    
    % Ensure that it was not already sampled
    while isnan( years(y,ens) )
        ens = ceil( randInterval(0,12,1) );
        y = ceil( randInterval(0,nYears,1) );
    end
    
    % Take the annual mean over the year and ensemble
    M(:,k) = mean( T(:,ens, y*12:y*12+11), 3);
    
    % Mark the year / ensemble so it is not selected again
    years(y,ens) = NaN;
end


%% Build the observation data, D

% For an initial run, just use the annual mean state vector at the site to
% run any forward models
%
% Use haversine to get the distance between each site and the state
% variables. Set the location to the closest state variable
stateVars = false( nState, nObs);

for k = 1:nObs
    dist = haversine( coordSite(k,:), coordM);
    
    stateVars(:,k) = dist==min(dist);
end

% Make the D cell
D = {crn', [latSite, lonSite], stateVars};


%% Get the uncertainty estimates

% R = ?


%% Get the model estimates

% Set the forward model
% H = @?

% Ye = H(?)