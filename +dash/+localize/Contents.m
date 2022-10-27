%% dash.localize  Functions that implement covariance localization
% ----------
%   The dash.localize package facilitates the implementation of covariance
%   localization. The functions in this package calculate covariance
%   localization weights for a Kalman Filter using different methods.
% ----------
% Gaspari-Cohn:
%   gc2d    - Calculates localization weights over a 2D spatial field using a 5th order Gaspari-Cohn polynomial
%   gc1d    - Calculates localization weights over a 1D depth/height/Z dimension using a Gaspari-Cohn 5th order polynomial
%
% Tests:
%   tests   - Implements unit tests for the dash.localize package
%
% <a href="matlab:dash.doc('dash.localize')">Documentation Page</a>