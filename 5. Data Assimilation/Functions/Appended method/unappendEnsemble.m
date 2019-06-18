function[Amean, Avar, Ymean, Yvar] = unappendEnsemble( Amean, Avar, nObs )
%% Unappends a model posterior after the appended DA method.
%
% [Amean, Avar, Yf] = unappendEnsemble( Amean, Avar, nObs )
%
% ----- Inputs -----
%
% Amean: The ensemble mean posterior from an appended assimilation.
%       (nState + nObs x nTime)
%
% Avar: The ensemble variance posterior from an appended assimilation.
%       (nState + nObs x nTime)
%
% nObs: The number of observations / proxies in an appended assimilation.
%       (1 x 1).
%
% ----- Outputs -----
%
% Amean: The ensemble mean posterior from an appended assimilation.
%       (nState x nTime)
%
% Avar: The ensemble variance posterior from an appended assimilation.
%       (nState x nTime)
%
% Ymean: The final Ye means from an appended assimilation. (nObs x nTime)
%
% Yvar: The final Ye variances from an appended assimilation. (nObs x nTime)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the number of state variables
nState = size(Amean,1) - nObs;

% Get the Ye indices in the state vector
ydex = nState + (1:nObs)';

% Get the Ye means and variances
Ymean = Amean( ydex, : );
Yvar = Avar( ydex, : );

% Remove the Ye from the end of the ensemble
Amean( ydex, : ) = [];
Avar( ydex, : ) = [];

end