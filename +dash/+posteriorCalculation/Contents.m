%% dash.posteriorCalculation  Classes that perform calculations using posterior deviations from a Kalman Filter
% ----------
%   The Interface class implements an interface for performing calculations
%   on the posterior deviations in a Kalman filter. This allows developers
%   to write plug-ins for new calculations, without needing to alter
%   "kalmanFilter.run". The use of these calculators allows users to
%   calculate values using the posterior, without needing to save the
%   (often very large) posterior as output.
%
%   Subclasses implement the actual calculations, and implement methods
%   that allow "kalmanFilter.run" to preallocate their output.
% ----------
% Abstract Interface:
%   Interface       - Interface for objects that perform calculations on the posterior deviations for a Kalman filter
%
% Concrete Subclasses:
%   variance        - Computes the variance across a posterior ensemble
%   percentiles     - Computes the percentiles across a posterior ensemble
%   weightedMean    - Calculates a weighted mean index for each member of a posterior ensemble
%
% Tests:
%   tests           - Unit tests for the package
%
% <a href="matlab:dash.doc('dash.posteriorCalculation')">Documentation Page</a>