function[weights, yloc] = temporalLocalization( siteTime, stateTime, R, scale )
%% Calculates temporal localization weights.
%
% ***Note: Assumes site and state vector time metadata uses the same units.
%
% [w, yloc] = dash.temporalLocalization( siteTime, ensMeta, R )
% Calculates temporal covariance localization weights for an ensemble.
% 
% [w, yloc] = dash.temporalLocalization( siteTime, stateTime, R )
% Calculates weights for user-defined state vector time points.
%
% [w, yloc] = dash.temporalLocalization( siteTime, stateTime, R, scale )
% Specifies a length scale to use in the Gaspari-Cohn polynomial.
%
% ----- Inputs -----
%
% siteTime: The time points for the observation sites. A vector. May be
%           either numeric data or datetime. (nObs x 1)
%
% ensMeta: An ensemble metadata object.
%
% stateTime: User defined time points for a state vector. Must use the same
%            units as siteTime. (nState x 1)
%
% R: The temporal cutoff radius. If siteTime is numeric, a numeric scalar
%    with the same units as siteTime. If siteTime is a datetime, a duration
%    object.
%
% scale: A scalar on the interval (0, 0.5]. Default is 0.5
%
% ----- Outputs -----
%
% w: The localization weights between each site and each state vector
%    element. (nState x nObs)
%
% yloc: The localization weights between sites. (nObs x nObs)

% Get defaults
if ~exist('scale','var')
    scale = [];
end
if isa(stateTime, 'ensembleMetadata')
    if ~isscalar(stateTime) 
        error('ensMeta must be a scalar ensembleMetadata object.');
    end
    stateTime = stateTime.timepoints;
end

% Error check
if ~isvector(siteTime)
    error('siteTime must be a vector');
elseif ~isvector(stateTime)
    error('stateTime must be a vector.');
elseif isnumeric(siteTime) && (~isnumeric(stateTime) || ~isnumeric(R))
    error('stateTime and R must be numeric when siteTime is numeric.');
elseif isdatetime(siteTime) && (~isdatetime(stateTime) || ~isduration(R))
    error('When siteTime is a datetime array, stateTime must be a datetime array and R must be a duration.');
end

% Get the temporal distances for datetime metadata (no bsx for datetime)
if isdatetime(siteTime)
    nState = length(stateTime);
    nSite = length(siteTime);
    wdist = NaN( nState, nSite );
    ydist = NaN( nSite, nSite );
    for k = 1:nSite
        wdist(:,k) = abs( years(siteTime(k) - stateTime) );
        ydist(:,k) = abs( years(siteTime(k) - siteTime) );
    end
    R = years( R );
    
% Distance for numeric metadata
else
    wdist = abs( siteTime' - stateTime );
    ydist = abs( siteTime' - siteTime );
end

% Use a gaspariCohn to get localization weights
weights = gaspariCohn( wdist, R, scale );
yloc = gaspariCohn( ydist, R, scale );

end