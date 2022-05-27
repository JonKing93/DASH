classdef kalmanFilter < dash.ensembleFilter
    %% kalmanFilter  Implement offline ensemble square root Kalman filters
    % ----------
    %   Intro
    % ----------
    %
  

    properties (SetAccess = private)

        %% Inflation

        inflationFactor;
        whichFactor;

        %% Localization

        wloc;
        yloc;
        whichLoc;

        %% Blending

        Cblend;
        Yblend;
        blendingWeights;
        whichBlend;

        %% Set covariance

        Cset;
        Yset;
        whichSet;

        %% Deviations

        returnDeviations = false;

        %% Posterior calculators

        calculations = cell(0,1);
        calculationNames = strings(0,1);
        calculationTypes = NaN(0,1);
    end
    properties (Constant)
        indexHeader = "index_";
    end

    methods

        % General
        varargout = label(obj, varargout);
        name = name(obj);

        % Data Inputs
        varargout = observations(obj, Y);
        varargout = estimates(obj, Ye, whichPrior);
        varargout = prior(obj, X, whichPrior);
        varargout = uncertainties(obj, R, whichR);

        % Covariance adjustments
        [varargout] = inflate(obj, factor, whichFactor)
        [varargout] = localize(obj, wloc, yloc, whichLoc)
        [varargout] = blend(obj, C, Ycov, weight, whichBlend)
        [varargout] = setCovariance(obj, C, Ycov, whichSet)

        % General covariance
        [varargout] = covariance(obj, t, s)
        [Knum, Ycov] = estimateCovariance(obj, t, s, Xdev, Ydev)
        [whichCov, nCov] = uniqueCovariances(obj, t)

        % Outputs
        [varargout] = deviations(obj, returnDeviations)
        [varargout] = variance(obj, returnVariance)
        [varargout] = percentiles(obj, percentages)
        [varargout] = index(obj, name, type, varargin)

        % Run
        output = run(obj);

        % Console display
        % disp

    end

    methods (Static)
        varargout = validateSizes(varargout, type, name, header);
        tests;
    end


    % Constructor
    methods
        function[obj] = kalmanFilter(varargin)
            %% kalmanFilter.kalmanFilter  Create a new kalmanFilter object
            % ----------
            %   obj = kalmanFilter
            %   Initializes a new Kalman filter object. The new object
            %   does not have observations, estimates, uncertainties, or a
            %   prior. The algorithm will only return the ensemble mean
            %   when run.
            %
            %   obj = kalmanFilter(label)
            %   obj = kalmanFilter(labels)
            %   Also applies a label to the Kalman filter object. If
            %   unset, the label is set to an empty string. If labels is a
            %   string array, returns an array of Kalman filter objects
            %   and applies the corresponding label to each individual
            %   Kalman filter.
            %
            %   obj = kalmanFilter(size)
            %   obj = kalmanFilter(size, labels)
            %   Initializes an array of Kalman filter objects of the
            %   indicated size. Optionally also applies a label to each
            %   object in the array. If applying labels, the size of the
            %   "labels" array must match the requested size of the
            %   kalmanFilter array.
            % ----------
            %   Inputs:
            %       labels (string array | cellstring array | char row vector): Labels
            %           for the elements of a kalmanFilter array. If the only input,
            %           the output array will have the same size as labels. If combined
            %           with the "size input, must be the size of the requested array.
            %       size (row vector, positive integers): Indicates the size of the
            %           requested array of kalmanFilter objects. Must have at least 2
            %           elements, and all elements must be non-negative integers.
            %
            %   Outputs:
            %       obj (scalar kalmanFilter object | kalmanFilter array): A new
            %           kalmanFilter object or an array of kalmanFilter objects.
            %
            % <a href="matlab:dash.doc('kalmanFilter.kalmanFilter')">Documentation Page</a>
            
            % Header
            header = "DASH:kalmanFilter";

            % Parse inputs
            [siz, labels] = dash.parse.constructorInputs(varargin, header);

            % Build kalman filter array
            obj = repmat(obj, siz);

            % Apply labels
            dash.assert.sameSize(labels, obj, 'the "labels" input', 'the requested kalmanFilter array', header);
            labels = num2cell(labels);
            [obj.label_] = labels{:};
        end
    end

end