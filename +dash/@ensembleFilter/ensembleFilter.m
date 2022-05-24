classdef (Abstract) ensembleFilter
    %% ensembleFilter  Implement common utilities for ensemble-based data assimilation filters
    % ----------

    properties (SetAccess = protected)
        
        %% General

        label_;             % A label for the filter
        isfinalized = 0;    % Indicates finalization status: 0-Not finalized, 1-Finalized excluding prior, 2-Finalized including prior

        %% Sizes

        nState = 0;         % The number of state vector elements
        nMembers = 0;       % The number of ensemble members
        nPrior = 0;         % The number of priors
        nSite = 0;          % The number of proxy/observation sites
        nTime = 0;          % The number of assimilated time steps
        nR = 0;             % The number of observation uncertainties

        %% Essential inputs
        
        Y;                  % Proxy records / observations
        Ye;                 % Proxy estimates / observation estimates

        X;                  % The prior
        Xtype = NaN         % Indicates the type of prior: NaN-Unset, 0-numeric array, 1-scalar ensemble object, 2-vector of ensemble objects
        precision = "";     % Indicates the numerical precision of the prior
        whichPrior          % Indicates which prior to use in each assimilated time step

        R;                  % Proxy uncertainties / observation uncertainties
        Rtype = NaN;        % Indicates the type of uncertainties: NaN-Unset, 0-error variances, 1-error covariances
        whichR;             % Indicates which set of uncertainties to use in each assimilated time step

    end

    methods

        % General
        varargout = label(varargin);
        name = name(obj);
        obj = finalize(obj, requirePrior, actionName, header);

        % Essential inputs
        [outputs, type] = observations(obj, header, Y);
        [outputs, type] = prior(obj, header, X, whichPrior);
        [outputs, type] = estimates(obj, header, Ye, whichPrior);
        [outputs, type] = uncertainties(obj, header, R, whichR)

        % Input utilities
        assertValidR(obj, header);
        obj = processWhich(obj, whichArg, field, nIndex, indexType, ...
                                            timeIsSet, whichIsSet, header);

        % Query values
        Rcov = Rcovariance(t, s);
        X = loadPrior(p);
        
    end

end