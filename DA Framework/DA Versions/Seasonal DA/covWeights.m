function[w] = covWeights( varargin )
%% This calculates covariance weights to use with DA
% 
% w = covWeights( 'none' )
% Returns a scalar w = 1 for unadjusted covariance.
%
% covWeights( 'inflate', factor )
% Inflates covariance by a scalar factor.
%
% wloc = covWeights( 'localize', siteCoord, stateCoord, R, scaleArg)
% Applies a covariance localization to each site.
%
%
% ----- Inputs -----
%
% factor: A scalar factor used to inflate covariance
%
% siteCoord: Lat-lon coordinates of observation sites. (nObs x 2)

% stateCoord: Lat-lon coordinates of state variables. (nObs x 2)
%
% R: A cutoff radius for localization.
%
% scaleArg: Three options
%    [] or unspecified: Sets the length scale to 1/2 the cutoff radius.
%    'optimal': Sets the length scale to the optimal length of sqrt(10/3), as per Lorenc, 2003.
%    scale: A scalar on the domain (0, 0.5]: Scales less than 1/2 will
%       impose a more strict localization radius than the cutoff radius.
%
% ----- Outputs -----
%
% w: A scalar value of 1. Leaves covariance unadjusted.
%
% w inflate: ?
%
% wloc: A cell array of localization weights. Each element contains the
%    weight for each state variable for a particular observation site. {nObs x 1}(nState x 1)
%
% ----- Written By -----
%
% Jonathan King, 2018, University of Arizona

% Use unadjusted covariance
if strcmpi( varargin{1}, 'none' )
    w = 1; %ones(nState, nObs);

% Doing covariance inflation
elseif strcmpi( covArgs{1}, 'inflate' )
    factor = covArgs{2};
    w = factor * ones(nState, nObs);
    
% Covariance localizaton
elseif strcmpi( varargin{1}, 'localize' )
    
    % Preallocate the weights
    nSite = size( varargin{2}, 1);
    w = cell( nSite, 1 );
    
    % Get the localization for each site
    for s = 1:nSite
        w{s} = covLocalization( varargin{2}(s,:), varargin{3:end} );
    end
    
% Anything else...
else
    error('Unrecognized covariance adjustment.');
end

end