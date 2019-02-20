function[X] = qdm(Xo, Xm, Xp, type)
%% Quantile delta mapping
%
% X = qdm(Xo, Xm, Xp)
% Do quantile delta mapping while preserving relative changes.
% 
% X = qdm(Xo, Xm, Xp, type)
% Specify whether to preserve relative or absolute change in quantiles.
%
% ----- Inputs -----
%
% Xo: Observed values
%
% Xm: Modeled historical values analogous to the observed values
%
% Xp: Model projected values
%
% type: A string flag
%       'rel': Preserve relative changes in quantiles
%       'abs': Preserve absolute changes in quantiles
%
% ----- Outputs -----
%
% X: The bias-corrected future values

% Check that Xs and Xt and Xp are vectors
if ~isvector(Xs) || ~isvector(Xt) || ~isvector(Xp)
    error('Xs, Xt, and Xp must all be vectors.');
end

% Use relative qdm by default
if ~exist(type, 'var')
    type = 'rel';
elseif ~ismember( type, {'rel','abs'} )
    error('Unrecognized qdm type');
end

% Get the tau values (quantiles) for the projected values
tau = getTau(Xp);

% If preserving relative changes
if strcmpi(type, 'rel')
    
    % Get the relative change in the value associated with the quantile
    delta = Xp ./ quantile(Xm, tau);
    
    % Get the bias corrected values
    X = quantile(Xo, tau) .* delta;
    
% If preserving absolute changes
elseif strcmpi(type, 'abs')
    
    % Get the absolute change
    delta = Xp - quantile(Xm,tau);
    
    % Get the bias corrected values
    X = quantile(Xo, tau) + delta;
end

end