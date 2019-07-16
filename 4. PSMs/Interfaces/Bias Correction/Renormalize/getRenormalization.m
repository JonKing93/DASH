function[slope, intercept] = getRenormalization( Xt, Xs )
% Xt is the real world
% Xs is the prior ensemble
% Get the mean and std used to zscore the source data
[~, meanS, stdS] = zscore( Xs );

% Get the mean and std of the target data
[~, meanT, stdT] = zscore( Xt );

% Get the renormalization
slope = (stdT ./ stdS);
intercept = meanT - (stdT .* meanS ./ stdS);

end