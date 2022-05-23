classdef particleFilter < dash.ensembleFilter
    %% particleFilter  Implement a particle filter assimilation
    % ----------
    %   The particleFilter class provides objects that perform particle
    %   filter assimilations. The following is a brief sketch of the
    %   particle filter algorithm: For an assimilated time step, the method
    %   determines the differences between proxy observations and estimates
    %   (known as the innovations). These innovations are then weighted by the
    %   proxy uncertainties. The algorithm then calculates the sum of these
    %   weighted innovations for each member of an ensemble. The smaller
    %   the sum, the more closely the ensemble member resembles the
    %   observation. The algorithm then uses these sums to compute a weight
    %   for each ensemble member, and takes a weighted mean of the ensemble
    %   members. This weighted mean is the updated state vector for that
    %   time step.
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
    % ----------
    % particleFilter Methods:
    %
    % *KEY METHODS*
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
    % **ALL USER METHODS**
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
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. They do not implement error
    % checking and are not intended for users.
    %
    % Weighting Schemes:
    %   bayesWeights    - Calculates particle weights using the classical Bayesian scheme
    %   bestNWeights    - Calculate weights that implement an average over the best N particles
    %
    % Size Validation:
    %   validateBestN   - Ensure that "Best N" weighting scheme is valid
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

        % Inputs
        varargout = observations(obj, Y);
        varargout = estimates(obj, Ye, whichPrior);
        varargout = prior(obj, X, whichPrior);
        varargout = uncertainties(obj, R, whichR);

        % Select weighting scheme
        obj = weights(obj, type, varargin)

        % Calculations
        sse = sse(obj);
        [weights, sse] = computeWeights(obj);
        output = run(obj, varargin);

        % Validate sizes
        obj = validateBestN(obj, type, name, header);
    end

    methods (Static)

        % Weighting schemes
        weights = bayesWeights(sse);
        weights = bestNWeights(sse, N);
    end

    % Constructor
    methods
        function[obj] = particleFilter(varargin)

end

