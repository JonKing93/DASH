function[] = settings( obj, varargin )
% Specifies settings for an optimal sensor analysis
%
% obj.settings( ..., 'replace', replace )
% Specifies whether to select sensors with or without replacement. Default
% is with replacement.
%
% obj.settings( ..., 'nSensor', N )
% Set the number of sensors to locate. Default is 1.
%
% obj.settings( ..., 'radius', R )
% Limits the selection of new sensors outside of a distance radius of
% selected sensors.
%
% ----- Inputs -----
%
% replace: Scalar logical. True: select sensors with replacement.
%
% N: The number of sensors. A scalar, positive integer.
%
% R: The radius used to limit sensor placement. Units are km.

% Parse the inputs
[replace, N, radius] = parseInputs( varargin, {'replace', 'nSensor', 'radius'},...
    {obj.replace, obj.nSensor, obj.radius}, {[],[],[]} );

% Error check
if ~isscalar(replace) || ~islogical(replace)
    error('replace must be a scalar logical.');
elseif ~isnumeric(N) || ~isscalar(N) || N<=0 || mod(N,1)~=0
    error('N must be a positive scalar integer.');
elseif ~isnumeric(radius) || ~isscalar(radius) || radius<0
    error('radius must be a scalar, non-negative number.');
end

% Save the settings
obj.replace = replace;
obj.nSensor = N;
obj.radius = radius;

end