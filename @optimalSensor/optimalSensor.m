classdef optimalSensor
    %% optimalSensor  Implement optimal sensor assimilations
    % ----------
    %   Introduction
    % ----------
    %
    % Create


    properties
        %% General
        
        label_;     % A label for the optimal sensor

        %% Inputs

        Ye;         % Observation estimates
        R;          % Observation uncertainties
        Rtype;      % The type of uncertainties: NaN-Unset, 0-Variances, 1-Covariances

        X;          % The prior
        Xtype;      % The type of prior: NaN-Unset, 0-Numeric Array, 1-Ensemble object
        precision;  % The numerical precision of the prior

        %% Sizes

        nSite = 0;      % The number of observation sites
        nState = 0;     % The number of state vector elements in the prior
        nMembers = 0;   % The number of ensemble members
    end

    methods

        % General
        varargout = label(obj, label);
        name = name(obj);

        % Essential inputs
        varargout = prior(obj, X);
        obj = metric(obj, type, varargin);
        varargout = estimates(obj, Ye, R);

        % Analyses
        [variance, metric] = update(obj);
        [variance, metric] = evaluate(obj);
        [optimalSites, variance, metric] = run(obj, N);

        % Utilities
        Rvar = Rvariances(obj);
    end
    methods (Static)
        deltaVar = varianceReduction(Jdev, Ydev, Rvar, unbias);
    end

    % Constructor
    methods
        function[obj] = optimalSensor(varargin)
            %% optimalSensor.optimalSensor  Create a new optimalSensor object
            % ----------
            %   obj = optimalSensor
            %   Initializes a new optimalSensor object. The new object does
            %   not have a prior, metric, or estimates.
            %
            %   obj = optimalSensor(label)
            %   obj = optimalSensor(labels)
            %   Also applies a label to the optimal sensor object. If
            %   unset, the label is set to an empty string. If labels is a
            %   string array, returns an array of optimal sensor objects
            %   and applies the corresponding label to each individual
            %   optimal sensor.
            %
            %   obj = optimalSensor(size)
            %   obj = optimalSensor(size, labels)
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