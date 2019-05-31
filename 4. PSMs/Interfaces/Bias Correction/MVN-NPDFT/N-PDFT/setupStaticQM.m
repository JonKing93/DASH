function[tauT, tauS, Xt, Xs] = setupStaticQM( Xt, Xs, type )
%% Runs a quantile mapping for a calibration period and returns the values
% needed to apply the same mapping to data outside the calibration period.
%
% [tauT, tauS] = setupStaticQM( Xt, Xs, 'stable' )
% Returns the tau (cumulative probability) values associated with the
% elements of Xt and Xs.
%
% [tauT, tauS, Xt, Xs] = setupStaticQM( Xt, Xs, 'sorted' )
% Sorts the datasets before assigning tau values and also returns the
% sorted datasets.
%
% ----- Inputs -----
%
% Xt: Target data vector from the calibration period. (nTarget x 1)
%
% Xs: Source data vector from the calibration period. (nSource x 1)
%
% ----- Outputs -----
%
% Xt: Sorted target data from the calibration period. (nTarget x 1)
%
% tauT: The tau (cumulative probability) values for the sorted Xt. (nTarget x 1)
%
% Xs: Sorted source data from the calibration period. (nSource x 1)
%
% tauS: The tau values for the sorted Xs. (nSource x 1)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Throw error if the calibration source data contains duplicate values
% (Might want to look for a workaround later...)
if numel(unique(Xs)) ~= numel(Xs)
    error('The calibration source data may not contain duplicate values.');
end

% Get the sorting type
if ~ismember( type, ["stable","sorted"] )
    error('The third input must be either "stable" or "sorted".');
end

% Sort Xt and get the tau values
[Xt, tauT] = getSortedTaus( Xt, type );

% Do the same for the source data
[Xs, tauS] = getSortedTaus( Xs, type );

end

% Helper function.
function[X, tau] = getSortedTaus( X, type )

% Get the sorting order of the dataset
[Xsort, sortDex] = sort(X);

% Get the sorted set of tau values
N = length(X);
tau = ((1:N) - 0.5) ./ N;

% If returning sorted values, use the sorted dataset
if strcmp( type, 'sorted' )
    X = Xsort;
    
% If not sorting, reverse sort the tau
else
    tau(sortDex) = tau;
end

end