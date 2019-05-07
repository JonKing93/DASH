function[X] = QM_static( Xd, Xt, tauT, Xs, tauS )
%% This performs a static quantile mapping. It applies the quantile map from
% a calibration period to data outside of the calibration period.
%
% X = QM_static( Xd, Xt, tauT, Xs, tauS )
%
% ----- Inputs -----
%
% Xd: A vector of data from outside of a calibration period. (nData x 1)
%
% Xt, tauT, Xs, tauS: See the "setupStaticQM.m" function.
%
% ----- Outputs -----
%
% X: Bias-corrected values for Xd generated from the quantile mapping for
%    the calibration period. (nData x 1)

% Convert any Xd outside the range of Xs to the min or max of Xs
Xd( Xd > max(Xs) ) = max( Xs );
Xd( Xd < min(Xs) ) = min( Xs );

% Interpolate between Xs and Xd to get the tau values associated with Xd
tauD = interp1( Xs, tauS, Xd );

% Lookup the values associated with these tau in the target dataset
X = interp1( tauT, Xt, tauD);

end