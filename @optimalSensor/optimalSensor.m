classdef optimalSensor
    %% optimalSensor

    properties
        %% General
        
        label_;     % A label for the optimal sensor

        %% Inputs

        Ye;         % Observation estimates
        R;          % Observation uncertainties
        Rtype;      % The type of uncertainties: NaN-Unset, 0-Variances, 1-Covariances

        X;          % The prior
        Xtype;      % The type of prior: NaN-Unset, 0-Numeric Array, 1-Ensemble object
        precision;  % The number precision of the prior

        %% Sizes

        nSite;      % The number of observation sites
        nState;     % The number of state vector elements in the prior
        nMembers;   % The number of ensemble members
    end
