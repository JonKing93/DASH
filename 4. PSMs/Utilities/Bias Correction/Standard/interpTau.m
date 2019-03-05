function[tau] = interpTau(Xs, tau, Xd)
%% Interpolates tau values. If Xs contains non-unique values, sets tau
% to the maximum value for each quantile
%
% tau = getTau(X)
%
% ----- Inputs -----
%
% Xs: Source data
%
% tau: Tau values for the source data
%
% Xd: Static lookup values.
%
% ----- Outputs -----
%
% tau: The empirical quantile value of each element in Xd.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Ensure is vector
if ~isvector(Xs) || ~isvector(tau) || ~isvector(Xd)
    error('Xs, tau, and Xd must be vectors');
elseif length(Xs)~=length(tau)
    error('The length of Xs must match the length of tau.');
end

% Attempt to interpolate to Xd.
try
    tau = interp1( Xs, tau, Xd );
    
% If the Xs contains duplicate points, set them to the highest
% quantile. We're using a try-catch setup because the call to unique is
% expensive, and we want to avoid it unless absolutely necessary.
catch ME
    if strcmp(ME.identifier, 'MATLAB:griddedInterpolant:NonUniqueCompVecsPtsErrId')

        % Use the highest tau valule for duplicate quantiles
        [~, uA, uC] = unique(X, 'last');
        tau = tau(uA);
        tau = tau(uC);
        
        % Retry the interpolation
        tau = interp1( Xs, tau, Xd );
    
    % If the error was for something else, rethrow the error
    else
        rethrow(ME);
    end
end

end