function[output] = run( obj )
% Does an optimal sensor test for a specific sensorTest object.
%
% output = obj.run
%
% ----- Outputs -----
%
% output: A structure with the following fields
%
%   settings - Settings used to run the analysis
%
%   bestH - The state vector indices of the best sites
%
%   bestSites - The index of the best sites in the sensorSites object
%
%   skill - The relative reduction in J variance of each placement.

% Run
output = obj.optimalSensor( obj.M, obj.Fj, obj.S, obj.nSensor, obj.replace, obj.radius );

end