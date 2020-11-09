function[kf] = inflate(kf, inflateFactor)
%% Specify an inflation factor.
%
% kf = kf.inflate( inflateFactor )
%
% ----- Inputs -----
%
% inflateFactor: An inflation factor. A positive scalar.
%
% ----- Outputs -----
%
% kf: The updated kalman filter object

% Error check
assert( isnumeric(inflateFactor), 'inflateFactor must be numeric');
dash.assertRealDefined(inflateFactor, 'inflateFactor');
assert( isscalar(inflateFactor), 'inflateFactor must be scalar');
assert(inflateFactor>=1, 'inflateFactor cannot be smaller than 1.');

% Save
kf.inflateFactor = inflateFactor;

end