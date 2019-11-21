function[Ye] = calculateYe( M, F )
%% Calculates Ye for a given ensemble and set of PSMs without conducting
% any data assimilation.
%
% Ye = dash.calculateYe( M, F )
% Calculate Ye values.
%
% ----- Inputs -----
%
% M: A model ensemble (nState x nEns), or a scalar ensemble object.
%
% F: A set of forward models
%
% ----- Outputs -----
%
% Ye: A set of Ye values

% Initialize an empty Kalman Filter, just to error check M and F
kalmanFilter( M, ones(size(F)), ones(size(F)), F );

% Preallocate
nObs = size(F,1);
nEns = size(M,2);
Ye = NaN( nObs, nEns );

% Generate model estimates
for d = 1:numel(F)
    Mpsm = M( F{d}.H, : );
    Ye(d,:) = dash.processYeR( F{d}, Mpsm, 1, NaN, d );
end

end