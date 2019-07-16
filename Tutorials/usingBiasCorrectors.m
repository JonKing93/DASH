%% How to implement bias correctors

% Get a list of available correctors
helpBiasCorrectors;

% See details on a specific corrector
helpBiasCorrectors( 'mean' );
helpBiasCorrectors( 'renorm' );


% Assume a model prior, associated metadata, and some uk37 sites
M;
ensMeta;
ukLat;
ukLon;

% Also assume some target dataset containing "true" values at each of the
% uk37 sites.
target;   % (nSite x nTime)

% PSM creation
for s = 1:nSites
    
    % Initialize the PSMs
    F{s} = ukPSM( ukLat(s), ukLon(s) );
    
    % Get the state indices
    F{s}.getStateIndices( ensMeta, 'SST' );
    
    
    %% Using the mean adjustment.
    
    % Get the additive constant needed to adjust the mean of the model
    % prior for each PSM
    addConstant = getMeanAdjustment( Xt(s,:),  M( F{s}.H, : ) );
    
    % Alternatively, assume the additive constant was calculated previously
    % by the user. Then:
%     addConstant = myListOfConstants(s);
    
    % Activate the bias corrector
    F{s}.useMeanCorrector( addConstant );
    
    
    %% Using the renormalization corrector
    
    % Get the additive and multiplicative constants needed to adjust the
    % mean and standard deviation of the prior for each PSM
    [timesConstant, addConstant] = getRenormalization( Xt(s,:),  M( F{s}.H, :) );
    
    % Activate the bias corrector
    F{s}.useRenormCorrector( timesConstant, addConstant );
    
end