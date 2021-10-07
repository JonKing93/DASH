function[Mmean, Mdev] = decompose(M, dim)
%% Decomposes an ensemble into mean and deviations
%
% Mmean = decompose(M)
% Returns the ensemble mean.
%
% [Mmean, Mdev] = decompose(M)
% Also returns the ensemble deviations.
%
% [...] = decompose(M, dim)
% Specify which dimension is the ensemble dimension. Default is the second
% dimension.
%
% ----- Inputs -----
%
% M: An ensemble. A numeric array. Default size: (nState x nEns)
%
% dim: A scalar integer. Specifies which dimension is the ensemble
%    dimension. By default, the second dimension is used as the ensemble
%    dimension.
%
% ----- Outputs -----
%
% Mmean: The ensemble mean. Default size: (nState x 1)
%
% Mdev: The ensemble deviations. Default size: (nState x nEns)

% Default ensemble dimension
if ~exist('dim','var') || isempty(dim)
    dim = 2;
end

% Ensemble mean
Mmean = mean(M, dim);

% Deviations
if nargout>1
    Mdev = M - Mmean;
end

end
