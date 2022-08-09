classdef particleFilter < dash.ensembleFilter
    %% particleFilter  Implement a particle filter assimilation
    % ----------
    %   The particleFilter class provides objects that perform particle
    %   filter assimilations. This assimilation method uses a Bayesian
    %   formula to quantify the similarity of ensemble members (particles)
    %   to a set of proxy observations. The state vector is then updated
    %   using a weighted mean of the ensemble members. The weight of each
    %   ensemble member is a function of its similarity to the proxy
    %   observations. A more detailed sketch of the algorithm is provided
    %   below.
    %
    %   Classical particle filters are often degenerate in paleoclimate
    %   contexts. Essentially, the best ensemble member receives a weight
    %   near 1, and the weights for all other ensemble members are near 0.
    %   When this occurs, the updated state vector is nearly identical to
    %   the best particle. This behavior is not always desirable, because
    %   the updated state vector is not informed by the other members of
    %   the ensemble. Thus, many particle filter implementations modify the
    %   particle weighting scheme to try and reduce this degeneracy.
    %
    %   In the DASH toolbox, the particleFilter class provides objects that
    %   help implement the particle filter algorithm. These objects provide
    %   methods that allow users to provide data inputs (such as
    %   observations) to the filter, select algorithm parameters (such as
    %   the weighting scheme), and run particle filter algorithms. 
    %
    %   OUTLINE:
    %   The following is a sketch for using the particleFilter class:   
    %     1. Use the "particleFilter" method to initialize a new particle filter
    %     2. Use the "observations", "estimates", "prior", and
    %        "uncertainties" methods to provide essential data inputs to
    %        the particle filter.
    %     3. Use the "weights" method to select a particle weighting scheme, and
    %     4. Use the "run" method to run the particle filter algorithm on
    %        the data inputs with the selected weighting scheme.
    %
    %     You can also use the "computeWeights" method to calculate particle
    %     weights, without needing to update a state vector. This reduces
    %     the computational expense of tasks that only require particle
    %     weights -- for example, testing a particle filter for degeneracy,
    %     or selecting ensemble members for use in an evolving prior.
    %
    %   ALGORITHM SKETCH:
    %   The following is a sketch of the particle filter algorithm:
    %   For an assimilated time step, the method determines the differences
    %   between proxy observations and estimates (known as the innovations). 
    %   These innovations are then weighted by the proxy uncertainties, and
    %   the algorithm computes the sum of these weighted innovations for
    %   each member of the ensemble. The result is the sum of squared
    %   errors (SSE) for each ensemble member. The SSE values measure the
    %   similarity of each ensemble member to the observations - the lower
    %   its SSE value, the more closesly an ensemble member resembles the
    %   observations. Next, the method applies a weighting scheme to the 
    %   SSE values to determine a weight for each ensemble member. Finally,
    %   the method uses these weights to take a weighted mean across the
    %   ensemble. The final weighted mean is the updated state vector for
    %   that time step.
    %
    %   TROUBLESHOOTING LARGE STATE VECTORS:
    %   Large state vector ensembles can overwhelm computer memory and may
    %   prevent a particle filter assimilation from running. If this
    %   occurs, it is useful to note that the update for each state vector
    %   element is independent of all other state vector elements. Thus,
    %   you can often circumvent memory issues by splitting the state vector
    %   into several smaller pieces and then assimilating each piece
    %   individually. The built-in "matfile" command can be helpful for
    %   saving/loading pieces of large ensembles iteratively.
    % ----------
    % particleFilter Methods:
    %
    % **KEY METHODS**
    % These methods are the most essential for users.
    %
    %   particleFilter  - Initializes a new particleFilter object
    %   observations    - Provide the observations for a particle filter
    %   estimates       - Provide the observation estimates for a particle filter
    %   uncertainties   - Provide the observation uncertainties for a particle filter
    %   prior           - Provide the prior for a particle filter
    %   weights         - Select the weighting scheme for a particle filter
    %   run             - Runs a particle filter assimilation    
    %
    %
    % *ALL USER METHODS*
    %   
    % Create:
    %   particleFilter  - Initializes a new particleFilter object
    %   label           - Return or apply a label for a particleFilter
    %
    % Data Inputs:
    %   observations    - Provide the observations for a particle filter
    %   estimates       - Provide the observation estimates for a particle filter
    %   uncertainties   - Provide the observation uncertainties for a particle filter
    %   prior           - Provide the prior for a particle filter
    %
    % Weights:
    %   weights         - Select the weighting scheme for a particle filter
    %
    % Calculations:
    %   run             - Runs a particle filter assimilation
    %   computeWeights  - Calculate the particle weights in each time step
    %   sse             - Calculate the sum of squared errors for each particle in each time step
    %
    % Console Display:
    %   disp            - Display a particleFilter object in the console
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. They do not implement error
    % checking and are not intended for users.
    %
    % Name:
    %   name            - Returns a name for use in error messages
    %
    % Weighting Schemes:
    %   bayesWeights    - Calculates particle weights using the classical Bayesian scheme
    %   bestNWeights    - Calculate weights that implement an average over the best N particles
    %
    % Size Validation:
    %   validateBestN   - Ensure that "Best N" weighting scheme is valid
    %
    % Inherited:
    %   dispFilter      - Display size and data input details in the console
    %   assertValidR    - Throw error if observations are missing R values in required time steps
    %   processWhich    - Parse and process whichR and whichPrior inputs
    %   finalize        - Ensure essential data inputs are present for an analysis
    %   loadPrior       - Load the requested prior from an evolving set
    %   Rcovariance     - Return R uncertainty covariances for queried time steps and sites
    %
    % Tests:
    %   tests           - Implement unit tests for the particleFilter class
    %
    % <a href="matlab:dash.doc('particleFilter')">Documentation Page</a>

    properties (SetAccess = private)
        weightType = 0;     % The weighting scheme: 0-Bayesian, 1-Best N particles
        weightArgs = {};    % Additional arguments to particle weighting functions
    end

    methods

        % Label
        varargout = label(obj, label);
        name = name(obj);

        % Inputs
        varargout = observations(obj, Y);
        varargout = estimates(obj, Ye, whichPrior);
        varargout = prior(obj, X, whichPrior);
        varargout = uncertainties(obj, R, whichR, type);

        % Weighting scheme
        obj = weights(obj, type, varargin)
        obj = validateBestN(obj, type, name, header);

        % Calculations
        sse = sse(obj);
        [weights, sse] = computeWeights(obj);
        output = run(obj, varargin);

        % Console display
        disp(obj);
    end

    methods (Static)

        % Weighting schemes
        weights = bayesWeights(sse);
        weights = bestNWeights(sse, N);
    end

    % Constructor
    methods
        function[obj] = particleFilter(varargin)
            %% particleFilter.particleFilter  Create a new particleFilter object
            % ----------
            %   obj = <strong>particleFilter</strong>
            %   Initializes a new particle filter object. The new object
            %   does not have observations, estimates, uncertainties, or a
            %   prior. The object uses a Bayesian particle weighting
            %   scheme.
            %
            %   obj = <strong>particleFilter</strong>(label)
            %   obj = <strong>particleFilter</strong>(labels)
            %   Also applies a label to the particle filter object. If
            %   unset, the label is set to an empty string. If labels is a
            %   string array, returns an array of particle filter objects
            %   and applies the corresponding label to each individual
            %   particle filter.
            %
            %   obj = <strong>particleFilter</strong>(size)
            %   obj = <strong>particleFilter</strong>(size, labels)
            %   Initializes an array of particle filter objects of the
            %   indicated size. Optionally also applies a label to each
            %   object in the array. If applying labels, the size of the
            %   "labels" array must match the requested size of the
            %   particleFilter array.
            % ----------
            %   Inputs:
            %       labels (string array | cellstring array | char row vector): Labels
            %           for the elements of a particleFilter array. If the only input,
            %           the output array will have the same size as labels. If combined
            %           with the "size input, must be the size of the requested array.
            %       size (row vector, positive integers): Indicates the size of the
            %           requested array of particleFilter objects. Must have at least 2
            %           elements, and all elements must be non-negative integers.
            %
            %   Outputs:
            %       obj (scalar particleFilter object | particleFilter array): A new
            %           particleFilter object or an array of particleFilter objects.
            %
            % <a href="matlab:dash.doc('particleFilter.particleFilter')">Documentation Page</a>
            
            % Header
            header = "DASH:particleFilter";

            % Parse inputs
            [siz, labels] = dash.parse.constructorInputs(varargin, header);

            % Build particle filter array
            obj = repmat(obj, siz);

            % Apply labels
            dash.assert.sameSize(labels, obj, 'the "labels" input', 'the requested particleFilter array', header);
            labels = num2cell(labels);
            [obj.label_] = labels{:};
        end
    end
end