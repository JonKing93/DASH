function[varargout] = jointKalman(type, varargin)
%% Splits apart the kalman calculations for the joint updates. This allows
% more efficient calculations and helps preserve memory.
%
% [Knum] = jointKalman( 'Knum', Mdev, Ydev, w )
%
% [K, Kdenom] = jointKalman( 'K', Knum, Ydev, yloc, R )
%
% [Ka] = jointKalman( 'Ka', Knum, Kdenom, R )

% If just getting the numerator
if strcmp(type, 'Knum')
    [Mdev, Ydev, w] = parseKalman( varargin );
    
    % Get the coefficient for an unbiased estimator
    unbias = 1 / (size(Ydev,2) - 1);
    
    % Get the numerator (localized covariance of M with Ye
    Knum = unbias .* (Mdev * Ydev');
    Knum = Knum .* w;
    
    % Return the output
    varargout = {Knum};
    
    
% If getting the denominator and full gain
elseif strcmp(type, 'K')
    [Knum, Ydev, yloc, R] = parseKalman( varargin );
    
    % Get the coefficient for an unbiased estimator
    unbias = 1 / (size(Ydev,2) - 1);

    % Convert R to diagonal matirx
    R = diag(R);

    % Get the kalman denominator
    Kdenom = unbias .* yloc .* (Ydev * Ydev') + R;
    
    % Get the full Kalman gain
    K = Knum / Kdenom;
    
    % Return the output
    varargout = {K, Kdenom};
    
    
% If getting the adjusted Kalman gain
elseif strcmp(type, 'Ka')
    [Knum, Kdenom, R] = parseKalman( varargin );

    % Convert R to diagonal matrix
    R = diag(R);
    
    % Get the adjusted kalman gain
    Ka = Knum * (sqrtm(Kdenom)^(-1))' * (sqrtm(Kdenom) + sqrtm(R))^(-1);
    
    % Return the output
    varargout = {Ka};
end

end

% Convenience function, lets you rename the inputs based on the specific
% calculation.
function[varargout] = parseKalman( input )
varargout = input;
end