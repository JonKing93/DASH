function[Xt, Xs, R, normT, normS, X, E, converged] = setupStaticNPDFT( Xt, Xs, tol, varargin )
%% Gets the initial values required to run a static N-PDFt.
% This includes the data normalizations and fixed rotation matrices.
%
% [Xt0, Xs0, R, normT, normS] = setupStaticNPDFT( Xt, Xs, tol )
% Use the Npdft method to map source data from a calibration period to
% target data from the calibration period. Iterate until the energy
% distance of the mapping is less than a threshold (tol). Returns values
% needed to replicate the mapping outside of the calibration period.
%
% [...] = setupStaticNPDFT( Xt, Xs, tol, nIter )
% Set a limit on the maximum number of iterations.
%
% [Xt, Xs, R, normT, normS, X, E, converged] = setupStaticNPDFT( ... )
% Also return standard Npdft output.
%
% ------ Inputs -----
%
% Xt: A target dataset from a calibration period. (nTarget x nVars)
%
% Xs: A source dataset from a calibration period. (nSource x nVars)
%
% tol: Energy-distance convergence threshold. (1 x 1)
%
% nIter: A maximum number of allowed iterations. (1 x 1)
%
% ----- Outputs -----
%
% Xt0: Standardized target data from the calibration period. (nTarget x nVars)
%
% Xs0: Standardized source data from the calibration period. (nSource x nVars)
%
% R: The rotation matrices used by the mapping. (nVars x nVars x nIter)
%
% normT: The mean and standard deviation used to normalize the target
%        calibration data. First row is mean, second is std. (2 x nVars)
%
% normS: The mean and standard deviation used to normalize the source
%        calibration data. First row is mean, second is std. (2 x nVars)
%
% X, E, converged: See "npdft.m" for details.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Standardize the datasets
[Xt, meanT, stdT] = zscore( Xt, 0, 1 );
[Xs, meanS, stdS] = zscore( Xs, 0, 1 );

% Record the normalization for both datasets
normT = [meanT; stdT];
normS = [meanS; stdS];

% Run the npdft and get the rotation matrices.
[X, E, converged, R] = npdft( Xt, Xs, tol, varargin{:} );

% Warn the user if the method did not converge
% if ~converged
%     warning('The N-PDFT algorithm did not converge.');
% end

end
