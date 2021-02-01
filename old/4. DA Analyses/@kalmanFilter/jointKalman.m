function[varargout] = jointKalman(type, varargin)
%% Splits apart the kalman calculations for the joint updates. This allows
% more efficient calculations and helps conserve memory.
%
% [Knum] = dash.jointKalman( 'Knum', Mdev, Ydev, w )
%
% [K, Kdenom] = dash.jointKalman( 'K', Knum, Ydev, yloc, R )
%
% [Ka] = dash.jointKalman( 'Ka', Knum, Kdenom, R )

% Get the (static) numerator
if strcmp(type, 'Knum')
    [Mdev, Ydev, w] = parseKalman( varargin );    
    unbias = 1 / (size(Ydev,2) - 1);
    
    Knum = unbias .* (Mdev * Ydev');
    Knum = Knum .* w;
    varargout = {Knum};
    
% Denominator and full gain
elseif strcmp(type, 'K')
    [Knum, Ydev, yloc, R] = parseKalman( varargin );    
    unbias = 1 / (size(Ydev,2) - 1);
    R = diag(R);

    Kdenom = unbias .* yloc .* (Ydev * Ydev') + R;    
    K = Knum / Kdenom;
    varargout = {K, Kdenom};    
    
% Adjusted gain
elseif strcmp(type, 'Ka')
    [Knum, Kdenom, R] = parseKalman( varargin );
    R = diag(R);
    
    Ka = Knum * (sqrtm(Kdenom)^(-1))' * (sqrtm(Kdenom) + sqrtm(R))^(-1);    
    varargout = {Ka};
end

end

% Convenience function, lets you rename the inputs based on the specific
% calculation.
function[varargout] = parseKalman( input )
varargout = input;
end