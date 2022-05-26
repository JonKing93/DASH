classdef (Abstract) ensembleFilter
    %% ensembleFilter  Implement common utilities for ensemble-based data assimilation filters
    % ----------
    %   The ensembleFilter class implements utilities that are used by both
    %   the Kalman Filter, and the particle filter. The primary purpose of
    %   this class is to parse and error check the essential data inputs to
    %   these filters. Specifically, the observations, uncertainties,
    %   estimates, and prior. The class also includes a utilities for
    %   loading specific priors or R covariances, and also for checking that
    %   a filter object has the inputs required to run an algorithm
    % ----------
    % ensembleFilter methods:
    %   
    % General:
    %   label       - Set or return a label for the filter
    %   name        - Return a name for use in error messages
    %   finalize    - Ensure that a filter object has the required inputs to run an algorithm
    %
    % Inputs:
    %   observations    - Parse and process observations for a filter
    %   prior           - Parse and process priors for a filter
    %   estimates       - Parse and process estimates for a filter
    %   uncertainties   - Parse and process uncertainties for a filter
    %
    % Error checking:
    %   parseWhich      - Processes whichR and whichPrior inputs
    %   assertValidR    - Ensures that observations do not have NaN uncertainties
    %
    % Query:
    %   Rcovariance     - Returns an R covariance matrix for queried time steps and sites
    %   loadPrior       - Loads a prior from an evolving set
    %
    % Tests:
    %   tests           - Unit tests for the ensembleFilter class
    %
    % <a href="matlab:dash.doc('dash.ensembleFilter')">Documentation Page</a>

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
        varargout = label(obj, varargin);
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
        Rcov = Rcovariance(obj, t, s);
        X = loadPrior(obj, p);
    end

    methods (Static)
        tests;
    end
end