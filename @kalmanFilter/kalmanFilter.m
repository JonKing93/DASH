classdef kalmanFilter < dash.ensembleFilter
    %% kalmanFilter  Implement a Kalman filter assimilation
    % ----------
    %   The kalmanFilter class provides objects that implement offline
    %   ensemble square root Kalman filters. This assimilation method
    %   proceeds by determining the differences between observations and a
    %   set of ensemble members. The ensemble members are then updated to 
    %   more closely resemble the observations using a Kalman gain matrix.
    %   The mean of the updated ensemble is typically used as the final
    %   reconstruction, and the spread of the updated ensemble helps quantify 
    %   reconstruction uncertainty. A more detailed sketch of the algorithm
    %   is provided below.
    %
    %   Kalman filters require an estimate of the cross covariance between
    %   the observation records and the reconstructed state vector
    %   elements. In a classical Kalman filter, this estimate is calculated
    %   using the cross covariance of the observation estimates with the
    %   prior ensemble. However, there are a number of methods
    %   that attempt to improve assimilated reconstructions by
    %   adjusting these covariances. The kalmanFilter class supports several
    %   commonly used covariance adjustments, including: inflation,
    %   localization, blending, and directly setting covariance. More
    %   details on these methods are provided below.
    %
    %   The kalmanFilter class uses an ensemble square root method, which
    %   updates the ensemble mean separately from ensemble deviations. The
    %   class always returns the updated mean, and allows users to
    %   optionally return the deviations. However, updated deviations can
    %   quickly overwhelm computer memory when running a Kalman filter for
    %   multiple time steps. Thus, the kalmanFilter class also provides
    %   several alternatives to returning the full set of updated
    %   deviations. Options include returning ensemble variance, 
    %   percentiles, and returning climate indices calculated from an 
    %   updated spatial field.
    %
    %   To summarize, the kalmanFilter class provides objects that help
    %   implement the Kalman filter algorithm. These objects provide
    %   methods that allow users to provide data inputs (such as
    %   observations and a prior) to the filter, select algorithm
    %   parameters (such as covariance adjustments), request specific
    %   outputs (such as ensemble variance or percentiles), and run the
    %   Kalman filter algorithm.
    %
    %   OUTLINE:
    %   The following is a sketch for using the kalmanFilter class:
    %     1. Use the "kalmanFilter" method to initialize a new kalmanFilter object
    %     2. Use the "observations", "estimates", "prior", and
    %        "uncertainties" methods to provide essential data inputs for
    %        the Kalman filter.
    %     3. Optionally use the "inflate", "localize", "blend", and 
    %        "setCovariance" methods to implement covariance adjustments.
    %     4. Optionally use the "deviations", "variance", "percentiles",
    %        and "index" methods to return information about the updated
    %        ensemble deviations.
    %     5. Use the "run" method to run the Kalman filter algorithm
    %
    %   ALGORITHM SKETCH:
    %   The following is a sketch of the Kalman filter algorithm.
    %   For an assimilated time step, the method first decomposes the prior
    %   ensemble and the observation estimates into their ensemble means
    %   and ensemble deviations. The method then uses the cross covariance
    %   of the prior with the estimates to estimate the covariance between
    %   the observation records and the state vector elements. Next, the
    %   method implements any covariance inflation, localization, and
    %   blending. The covariance estimate is combined with 1. the observation
    %   uncertainties and 2. the covariance of the estimates with one another
    %   to give the standard Kalman Gain matrix. Next, the method
    %   determines the differences between the observations and the proxy
    %   estimates (the innovations). The innovations are propagated through
    %   the Kalman gain and used to update the ensemble mean. The method
    %   may optionally also computes the adjusted Kalman Gain matrix. The
    %   adjusted gain is combined with the deviations of the estimates in
    %   order to update the ensemble deviations. Finally, the method
    %   extracts any requested information (such as ensemble variance or
    %   percentiles) from the updated deviations.
    %
    %   COVARIANCE ADJUSTMENTS:
    %   The following is a brief summary of supported covariance
    %   adjustments.
    %   1. Inflation: Inflation applies a multiplicative constant to the
    %      covariance estimate in order to increase the total covariance.
    %      This method is best used for online assimilations when the
    %      updated ensemble too closely resembles a single ensemble member.
    %      The inflation helps maintain variability in the updated ensemble
    %      by providing greater weight for the observation records.
    %   2. Localization: Localization limits the influence of proxy
    %      observations on distant state vector elements. This can help
    %      reduce the influence of spurious covariances resulting from
    %      finite ensemble sizes. The method allows proxy observations to
    %      inform nearby state vector elements, but not distant sites.
    %   3. Blending: Blending combines the covariance estimate with a
    %      second covariance estimate. This method is often used for
    %      evolving offline assimilations with small ensemble sizes. The
    %      second covariance is typically derived from a larger
    %      "climatological" ensemble. The method allows covariance
    %      estimates to partially evolve over time, while reducing spurious
    %      covariances that result from small ensemble sizes.
    %   4. Directly setting covariance: In some cases, it may be desirable
    %      to directly specify the covariance between the observation sites
    %      and state vector elements. This is often used for deep time
    %      assimilations, when changing continental configurations result
    %      in NaN covariances at many different spatial sites.
    %
    %   TROUBLESHOOTING LARGE STATE VECTORS:
    %   Large state vector ensembles can overwhelm computer memory and may
    %   prevent a Kalman filter assimilation from running. If this occurs,
    %   it is useful to note that the update for each state vector element
    %   is independent of all other state vector elements. Thus, you can
    %   often circumvent memory issues by splitting the state vector into
    %   several smaller pieces and then assimilating each piece
    %   individually. The built-in "matfile" command can be helpful for
    %   saving/loading pieces of large ensembles iteratively.
    % ----------
    % kalmanFilter Methods:
    %
    % *KEY METHODS*
    % These methods are the most essential for users.
    %
    %   kalmanFilter    - Initializes a new kalmanFilter object
    %   observations    - Provide the observations for a Kalman filter
    %   estimates       - Provide the observation estimates for a Kalman filter
    %   uncertainties   - Provide the observation uncertainties for a Kalman filter
    %   prior           - Provide the prior for a Kalman filter
    %   run             - Run the Kalman filter algorithm on the data inputs
    %
    %
    % **ALL USER METHODS**
    %
    % Create:
    %   kalmanFilter    - Initializes a new kalmanFilter object
    %   label           - Return or apply a label for a kalmanFilter
    %
    % Data Inputs:
    %   observations    - Provide the observations for a particle filter
    %   estimates       - Provide the observation estimates for a particle filter
    %   uncertainties   - Provide the observation uncertainties for a particle filter
    %   prior           - Provide the prior for a particle filter
    %
    % Covariance:
    %   inflate         - Implement covariance inflation
    %   localize        - Implement covariance localization
    %   blend           - Implement covariance blending
    %   setCovariance   - Directly set the covariance estimate
    %   covariance      - Return the covariance estimate used in a given time step
    %
    % Output options:
    %   variance        - Return the variance across the updated ensemble
    %   percentiles     - Return percentiles of the updated ensemble
    %   deviations      - Return the updated ensemble deviations
    %   index           - Calculate and return a climate index over each member of the updated ensemble
    %
    % Run:
    %   run             - Runs a Kalman filter assimilation
    %
    % Console Display:
    %   disp            - Display a Kalman filter object in the console
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. They do not implement error
    % checking and are not intended for users.
    %
    % General:
    %   name            - Returns a name for use in error messages
    %   processWhich    - Parse and process which* arguments for a Kalman filter
    %
    % Covariances:
    %   estimateCovariance  - Estimate covariance for a set of ensemble deviations
    %   uniqueCovariances   - Locate unique covariance estimates for a given set of time steps
    %   validateSizes       - Preserves Kalman filter sizes set by covariance options
    %   finalizeCovariance  - Finalize empty which* covariance properties
    %
    % Inherited:
    %   dispFilter      - Display size and data input details in the console
    %   assertValidR    - Throw error if observations are missing R values in required time steps
    %   finalize        - Ensure essential data inputs are present for an analysis
    %   loadPrior       - Load the requested prior from an evolving set
    %   Rcovariance     - Return R uncertainty covariances for queried time steps and sites
    %
    % Tests:
    %   tests           - Implement unit tests for the kalmanFilter class
    %
    % <a href="matlab:dash.doc('kalmanFilter')">Documentation Page</a>
    
    properties (SetAccess = private)

        %% Inflation

        inflationFactor;                % The set of inflation factors
        whichFactor;                    % Indicates which inflation factor to use in each time step

        %% Localization

        wloc;                           % Localization weights between the observation records and state vector elements
        yloc;                           % Localization weights between the observation records and one another
        whichLoc;                       % Indicates which set of localization weights to use in each time step

        %% Blending

        Cblend;                         % The climatological covariance between the observation records and state vector elements
        Yblend;                         % The climatological covariance between the observation records and one another
        blendingWeights;                % The blending ratio to use for each climatological covariance
        whichBlend;                     % Indicates which climatological covariance to blend in each time step

        %% Set covariance

        Cset;                           % The user-specified covariance between the observation records and state vector elements
        Yset;                           % The user-specified covariance between the observation records and one another
        whichSet;                       % Indicates which user-specified covariance to use in each time step

        %% Deviations

        returnDeviations = false;       % True if the Kalman filter should return updated ensemble deviations as output

        %% Posterior calculators

        calculations = cell(0,1);           % Objects that perform calculations using the updated deviations
        calculationNames = strings(0,1);    % Names for the objects that perform calculations
        calculationTypes = NaN(0,1);        % Indicates the type of calculation associated with each object: 0-variance, 1-percentiles, 2-climate index

    end
    properties (Constant)
        indexHeader = "index_";         % The prefix for climate indices in the output struct
    end

    methods

        % General
        varargout = label(obj, label);
        name = name(obj);
        obj = processWhich(obj, whichArg, field, nIndex, indexType, timeIsSet, whichIsSet, header);

        % Data Inputs
        varargout = observations(obj, Y);
        varargout = estimates(obj, Ye, whichPrior);
        varargout = prior(obj, X, whichPrior);
        varargout = uncertainties(obj, R, whichR, type);

        % Covariance adjustments
        [varargout] = inflate(obj, factor, whichFactor)
        [varargout] = localize(obj, wloc, yloc, whichLoc)
        [varargout] = blend(obj, C, Ycov, weight, whichBlend)
        [varargout] = setCovariance(obj, C, Ycov, whichSet)

        % General covariance
        [varargout] = covariance(obj, t, s)
        [Knum, Ycov] = estimateCovariance(obj, t, s, Xdev, Ydev)
        [whichCov, nCov] = uniqueCovariances(obj, t)
        obj = finalizeCovariance(obj)

        % Outputs
        [varargout] = deviations(obj, returnDeviations)
        [varargout] = variance(obj, returnVariance)
        [varargout] = percentiles(obj, percentages)
        [varargout] = index(obj, name, type, varargin)

        % Run
        output = run(obj);

        % Console display
        disp(obj);

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