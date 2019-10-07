function[output] = optimalSensor( obj, J, sites )
% Runs an optimal sensor test
%
% output = obj.optimalSensor( J, sites )
%
% ----- Inputs -----
%
% J: A metric vector. Often a climate index. (1 x nEns)
%
% sites: A sensorSites object
%
% ----- Outputs -----
%
% output: A structure with the following fields
%
%   settings - Settings used to run the analysis
%
%   bestSites - The state vector indices of the best sites
%
%   skill - The relative reduction in J variance of each placement.

% Error check
if ~isvector(J) || numel(J)~=obj.nEns
    error('J must be a vector with nEns elements (%.f)', obj.nEns );
elseif ~isa( sites, 'sensorSites' ) || ~isscalar(sites)
    error('sites must be a scalar sensorSites object.');
elseif any(sites.H) > obj.nState
    error('The state vector indices of the sensor sites (H) cannot be larger than the number of state vector elements (%.f).', obj.nState );
end
if iscolumn(J)
    J = J';
end

% Load the ensemble if necessary
M = obj.M;
if isa(M, 'ensemble')
    M = M.load;
end

% Get the current settings
set = obj.settings.optimalSensor;

% Run
output = dash.sensorTest( J, M, sites, set.N, set.replace, set.radius );

end