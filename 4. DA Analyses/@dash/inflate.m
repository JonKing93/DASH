function[M] = inflate( M, factor )
% Inflates the covariance of an ensemble.
%
% M = dash.inflate( M, factor )
%
% ----- Inputs -----
% 
% M: An ensemble. (nState x nEns)
%
% factor: An inflation factor. A scalar.
%
% ----- Outputs ----
%
% M: The inflated ensemble.

% Don't both inflating if the inflation factor is 1. 
if factor ~= 1
    [Mmean, Mdev] = dash.decompose( M );
    Mdev = sqrt(factor) .* Mdev;
    M = Mmean + Mdev;
end

end