function[Xs, Xd] = quantmap_static( Xt, Xs, Xd )
%% This does a static quantile mapping as efficiently as possible

% Check that Xs and Xt are vectors
if ~isvector(Xs) || ~isvector(Xt) || ~isvector(Xd)
    error('Xt, Xs, and Xd must be vectors.')
end

% Get the tau values associated with Xs
[~,sortDex] = sort(Xs);

% Get the quantile for each value
N = numel(Xs);
tau(sortDex,1) = 1:N;
tau = (tau-0.5) ./ N;

% Convert any Xd outside of the range of Xs to the min or max
Xd(Xd>max(Xs)) = max(Xs);
Xd(Xd<min(Xs)) = min(Xs);

% Try interpolating to the new tau values.
try
    tauD = interp1( Xs, tau, Xd);
    
% If there are duplicate values, set them to the highest tau. Using a
% try-catch block because the call to unique is expensive and we want to
% avoid it if possible.
catch ME
    if strcmp(ME.identifier, 'MATLAB:griddedInterpolant:NonUniqueCompVecsPtsErrId')

        % Use the highest tau value for duplicate quantiles
        [~, uA, uC] = unique(X, 'last');
        tau = tau(uA);
        tau = tau(uC);
        
        % Retry the interpolation
        tauD = interp1( Xs, tau, Xd );
    
    % If the error was for something else, rethrow the error
    else
        rethrow(ME);
    end
end

% Lookup the values
Xs = quantile( Xt, tau );
Xd = quantile( Xt, tauD );

end