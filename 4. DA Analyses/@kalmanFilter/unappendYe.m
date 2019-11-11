function[Amean, Avar] = unappendYe( Amean, Avar, nObs )
%% Unappends Ye values from a model posterior.
%
% [Amean, Avar] = dash.unappendYe( Amean, Avar, nObs )
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

% Get the indices of the appended estimates
ye = size(Amean,1) - nObs + (1:nObs)';

% Remove the Ye from the end of the ensemble
Amean( ye, : ) = [];
Avar( ye, : ) = [];

end