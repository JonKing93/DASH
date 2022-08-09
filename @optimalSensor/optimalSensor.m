classdef optimalSensor
    %% optimalSensor  Implement optimal sensor analyses
    % ----------
    %   The optimalSensor class provides objects that implement an optimal
    %   sensor algorithm and related analyses. These analyses help to
    %   evaluate the influence of different observation sites on a Kalman
    %   filter assimilation, and can also help determine ideal locations
    %   for future proxy record development. Here we implement the optimal
    %   sensor algorithm described by Comboul et al., 2015. In this method,
    %   potential observation sites are ranked by their ability to
    %   constrain a metric. The metric is distributed across an ensemble,
    %   and the rankings are determined using each site's ability to reduce
    %   the variance of the metric across the ensemble.
    %
    %   Note that the optimal sensor algorithm does not assimilate
    %   observations in order to produce a reconstruction. Instead, the
    %   algorithm helps quantify the effects of individual observation on
    %   an assimilation. As such, optimal sensor analyses can help 
    %   characterize recpmstructions produced using Kalman filters. Because
    %   they do not produce a reconstruction, optimal sensor analyses do
    %   not require observations. Aside from the sensor metric, they only
    %   require estimates and uncertainties.
    %
    %   In the classical optimal sensor algorithm, the sites are ranked and
    %   the site that most strongly constrains the metric (i.e. most
    %   strongly reduces metric variance) is deemed the "optimal sensor".
    %   This observation site is used to update the variance of the metric,
    %   and also the observation estimates. After updating, the optimal
    %   site is removed from the observation network, and the analysis
    %   repeats using the remaining observation sites. This algorithm
    %   iterates until the desired number of optimal sites have been
    %   selected. This algorithm is implemented using the "run" method.
    %
    %   The optimalSensor class also provides two auxiliary methods for
    %   implementing optimal sensors. In many cases, it can be useful to
    %   quantify the influence of the observation sites relative to one
    %   another without implementing the iterative algorithm. The
    %   "evaluate" method provides this analysis. Additionally, the
    %   classical optimal sensor algorithm neglects the effects of
    %   covarying error uncertainties (R covariances). When observation
    %   records *do* have covarying error uncertainties, the classical
    %   algorithm will overestimate the total variance constrained by the
    %   proxy network. You can instead use the "update" method to update
    %   metric variance in a manner that accounts for these covariances.
    %
    %   OUTLINE:
    %   The following is a sketch for using the optimalSensor class:
    %     1. Use the "optimalSensor" method to initialize a new optimalSensor object
    %     2. Use the "estimates", "uncertainties", and "metric" methods to
    %        provide essential data inputs for the optimal sensor.
    %     3. Use the "run", "evaluate", and "update" methods to implement
    %        optimal sensor analyses.
    % ----------
    % optimalSensor Methods:
    %
    % *USER METHODS*
    %
    % Create:
    %   optimalSensor       - Initializes a new optimalSensor object
    %   label               - Return or apply a label to an optimalSensor
    %
    % Data Inputs:
    %   metric              - Provide the metric for an optimal sensor
    %   estimates           - Provide the observation estimates for an optimal sensor
    %   uncertainties       - Provide the observation uncertainties for an optimal sensor
    %
    % Analyses:
    %   run                 - Iteratively identify optimal sites and update metric variance
    %   evaluate            - Return the variance constrained by each site when assimilated alone
    %   update              - Update metric variance for a network of covarying observation records
    %
    % Console Display:
    %   disp                - Display an optimalSensor object in the console
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. They do not implement error
    % checking and are not intended for users.
    %
    % Misc:
    %   Rvariances          - Return the error uncertainty variances for the observation sites
    %   assertFinalized     - Throw error if an optimal sensor does not have estimates, uncertainties, and a metric
    %   varianceReduction   - Calculate the metric variance reduced by each observation site
    %   
    % Tests:
    %   tests               - Implement unit tests for the optimalSensor class
    %
    % <a href="matlab:dash.doc('optimalSensor')">Documentation Page</a>

    properties (SetAccess = private)
        %% General
        
        label_ = "";    % A label for the optimal sensor

        %% Essential inputs

        J = [];         % The sensor metric
        Ye = [];        % Observation estimates
        R = [];         % Observation uncertainties
        Rtype = NaN;    % The type of uncertainties: NaN-Unset, 0-Variances, 1-Covariances

        %% Sizes

        nSite = 0;      % The number of observation sites
        nMembers = 0;   % The number of ensemble members
    end

    methods

        % General
        varargout = label(obj, label);
        name = name(obj);

        % Essential inputs
        varargout = metric(obj, J);
        varargout = estimates(obj, Ye);
        varargout = uncertainties(obj, R)

        % Analyses
        [variance, metric] = update(obj);
        [variance, metric] = evaluate(obj);
        [optimalSites, variance, metric] = run(obj, N);

        % Console display
        disp(obj);

        % Utilities
        Rvar = Rvariances(obj);
        assertFinalized(obj, actionName, header);
    end
    methods (Static)
        deltaVar = varianceReduction(Jdev, Ydev, Rvar, unbias);
    end

    % Constructor
    methods
        function[obj] = optimalSensor(varargin)
            %% optimalSensor.optimalSensor  Create a new optimalSensor object
            % ----------
            %   obj = <strong>optimalSensor</strong>
            %   Initializes a new optimalSensor object. The new object does
            %   not have a prior, metric, or estimates.
            %
            %   obj = <strong>optimalSensor</strong>(label)
            %   obj = <strong>optimalSensor</strong>(labels)
            %   Also applies a label to the optimal sensor object. If
            %   unset, the label is set to an empty string. If labels is a
            %   string array, returns an array of optimal sensor objects
            %   and applies the corresponding label to each individual
            %   optimal sensor.
            %
            %   obj = <strong>optimalSensor</strong>(size)
            %   obj = <strong>optimalSensor</strong>(size, labels)
            %   Initializes an array of optimal sensor objects of the
            %   indicated size. Optionally also applies a label to each
            %   object in the array. If applying labels, the size of the
            %   "labels" array must match the requested size of the
            %   optimal sensor array.
            % ----------
            %   Inputs:
            %       labels (string array | cellstring array | char row vector): Labels
            %           for the elements of an optimalSensor array. If the only input,
            %           the output array will have the same size as labels. If combined
            %           with the "size input, must be the size of the requested array.
            %       size (row vector, positive integers): Indicates the size of the
            %           requested array of optimalSensor objects. Must have at least 2
            %           elements, and all elements must be non-negative integers.
            %
            %   Outputs:
            %       obj (scalar optimalSensor object | optimalSensor array): A new
            %           optimalSensor object or an array of optimalSensor objects.
            %
            % <a href="matlab:dash.doc('optimalSensor.optimalSensor')">Documentation Page</a>

            % Header
            header = "DASH:optimalSensor";

            % Parse inputs
            [siz, labels] = dash.parse.constructorInputs(varargin, header);

            % Build optimal sensor array
            obj = repmat(obj, siz);

            % Apply labels
            dash.assert.sameSize(labels, obj, 'the "labels" input', 'the requested optimalSensor array', header);
            labels = num2cell(labels);
            [obj.label_] = labels{:};
        end
    end

end 