function[Ye, R] = run( obj, M, t, d )
% Interfaces PSMs between unit conversion, bias correction, dash, and the
% unique PSM instance.
%
% [Ye, R] = obj.runPSM( M, t, d )
%
% ----- Inputs -----
%
% M: The portion of the ensemble required to run the PSM. (nH x nEns)
%
% t: A time index. Use NaN for most purposes.
%
% d: An observation index. Use NaN for most purposes.
%
% ----- Outputs -----
%
% Ye: Model estimates (1 x nEns)
%
% R: R values associated with the observations. Includes dynamically
%    generated R.

% All PSMs should start by converting units
M = obj.convertUnits( M );

% They should then apply any bias correction
M = obj.biasCorrection.biasCorrect( M );

% And finally, run the forward model
[Ye, R] = obj.runForwardModel( M, t, d );

end
