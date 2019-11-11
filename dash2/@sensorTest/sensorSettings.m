function[] = sensorSettings( obj, varargin )
% Specifies settings for an optimal sensor analysis
%
% obj.sensorSettings( ..., 'replace', replace )
% Specifies whether to select sensors with or without replacement. Default
% is with replacement.
%
% obj.sensorSettings( ..., 'nSensor', N )
% Set the number of sensors to locate. Default is 1.
%
% obj.sensorSettings( ..., 'radius', R )
% Limits the selection of new sensors outside of a distance radius of
% selected sensors.
%
% ----- Inputs -----
%
% replace: Scalar logical. True: select sensors with replacement.
%
% N: The number of sensors. A scalar, positive integer.
%
% H: The state vector indices of sensors sites under consideration. Either
%    a logical vector with nState elements, or a vector of linear indices.
%
% R: The radius used to limit sensor placement. Units are km.

% Parse the inputs
curr = obj.settings.optimalSensor;
[replace, N, radius] = parseInputs( varargin, {'replace', 'nSensor', 'radius'},...
    {curr.replace, curr.nSensor, curr.radius}, {[],[],[]} );

% Error check
if ~isscalar(replace) || ~islogical(replace)
    error('replace must be a scalar logical.');
elseif ~isnumeric(N) || ~isscalar(N) || N<=0 || mod(N,1)~=0
    error('N must be a positive scalar integer.');
elseif N~=1
    error('Currently nSensor must equal 1. An update is in the works...');
elseif ~isnumeric(radius) || ~isscalar(radius) || radius<0
    error('radius must be a scalar, non-negative number.');
end

% Save the settings
obj.settings.optimalSensor = struct('replace', replace, 'nSensor', N, 'radius', radius );

end