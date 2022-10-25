classdef bayfox < PSM.Interface
    %% PSM.bayfox  Implements the BayFOX PSM, a Bayesian forward model for d18Oc of planktic foraminifera
    % ----------
    %   The BayFOX PSM is a Bayesian forward model that estimates d18Oc
    %   values of planktic foraminifera. The forward model is described in
    %   the paper:
    %
    %   Malevich, S. B., Vetter, L., & Tierney, J. E. (2019). Global Core Top
    %   Calibration of δ18O in Planktic Foraminifera to Sea Surface 
    %   Temperature. Paleoceanography and Paleoclimatology, 34(8), 1292-1315.
    %   DOI:  https://doi.org/10.1029/2019PA003576
    %
    %   Github Repository:  https://github.com/jesstierney/bayfoxm
    % ----------
    % bayfox Methods:
    %
    % *ALL USER METHODS*
    %
    % Create:
    %   bayfox      - Creates a new BayFOX PSM object
    %   label       - Apply a label to a BayFOX object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold BayFOX SST inputs
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates d18Oc values using SST values extracted from an ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.bayfox')">Documentation Page</a>

    % Description and repository
    properties (Constant)
        estimatesR = true;
        description = "Bayesian model for d18Oc of planktic foraminifera";
        hasMemory = false;           
        
        repository = "jesstierney/bayfoxm";
        commit = "cb98a5259c7340c3b19669c45a599799b9a491c2";
        commitComment = "Most recent as of June 28, 2022. Code updated on March 6, 2020.";
    end

    % Forward model parameters
    properties (SetAccess = private)
        species;    % The target species
    end

    methods
        function[obj] = bayfox(species)
            %% PSM.bayfox.bayfox  Creates a new BayFOX PSM object
            % ----------
            %   obj = <strong>PSM.bayfox</strong>(species)
            %   Initializes a new BayFOX PSM object. Please see the
            %   documentation of bayfox_forward.m in the BayFOX
            %   repository for details about the inputs.
            % ----------
            %   Inputs:
            %       species (string scalar): Name of the target species
            %
            %   Outputs:
            %       obj (scalar PSM.bayfox object): The new BayFOX PSM object
            %
            % <a href="matlab:dash.doc('PSM.bayfox.bayfox')">Documentation Page</a>
            
            % Error check
            header = "DASH:PSM:bayfox";
            dash.assert.strflag(species, 'species', header);

            % Record parameters
            obj.species = species;
        end
        function[output] = rows(obj, rows)
            %% PSM.bayfox.rows  Indicate the stateVector rows used to run a BayFOX PSM
            % ----------
            %   obj = <strong>obj.rows</strong>(rows)
            %   Indicate the state vector rows that should be used as input
            %   for the BayFOX PSM when calling "PSM.estimate". The input
            %   is a column vector with two elements. The first element is
            %   the row of the SST input, and the second element is the row
            %   of the d18O (seawater) input.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with 2 rows and
            %   one column per ensemble member. The first row is for the
            %   SST inputs, and the second row is the d18O (seawater) inputs.
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   Indicate which state vector row to use for different  ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [2 x 1 x nEvolving] or of size 
            %   [2 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same row for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use a different row for each ensemble member in each evolving ensemble.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows for the PSM object
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any currently specified rows from the BayFOX PSM object.
            % ----------
            %   Inputs:
            %       rows (column vector, linear indices [2]): The state vector rows
            %           required to run the PSM. A column vector with two elements. The
            %           first element is the row of the SST inputs and the second
            %           element is the row of the d18O_seawater inputs.
            %       memberRows (matrix, linear indices [2 x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
            %           be a matrix with two rows and one column per ensemble member.
            %           The first row is the SST inputs, and the second row is the
            %           d18O_seawater inputs.
            %       evolvingRows (3D array, linear indices [2 x 1|nMembers x nEvolving]):
            %           Indicates which state vector row to use for different ensembles
            %           in an evolving set. Should be a 3D array, and the number of
            %           elements along the third dimension should match the number of
            %           ensembles in the evolving set. If the second dimension has a
            %           length of 1, uses the same row for all the ensemble members in
            %           each evolving ensemble. If the second dimension has a length
            %           equal to the number of ensemble members, allows you to indicate
            %           which state vector row to use for each ensemble member in each
            %           evolving ensemble.
            %
            %   Outputs:
            %       obj (scalar bayfox object): The BayFOX PSM with updated rows
            %       rows (linear indices, [2 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the BayFOX PSM.
            %
            % <a href="matlab:dash.doc('PSM.bayfox.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                inputs = {rows, 2};
            end
            output = obj.parseRows(inputs{:});
        end
        function[d18Oc, R] = estimate(obj, X)
            %% PSM.bayfox.estimate  Estimates d18Oc values from SSTs and d18O_seawater
            % ----------
            %   [d18Oc, R] = <strong>obj.estimate</strong>(X)
            %   Runs the BayFOX forward model on data extracted from a
            %   state vector ensemble. Returns an estimate of d18Oc values 
            %   and optionally estimates uncertainties for the estimated values.
            % ----------
            %   Inputs:
            %       X (numeric array [2 x nMembers x nEvolving]):
            %           Sea surface temperatures and d18O_seawater values
            %           used as inputs to the BayFOX PSM.
            %
            %   Outputs:
            %       d18Oc (numeric matrix [1 x nMembers x nEvolving]):
            %           d18Oc estimates generated from SST and
            %           d18O_seawater values using the BayFOX forward model
            %       R (numeric matrix [1 x nMembers x nEvolving]): Uncertainty
            %           estimates for each d18Oc value.
            %
            % <a href="matlab:dash.doc('PSM.bayfox.estimate')">Documentation Page</a>

            % Get the climate inputs
            SST = X(1,:,:);
            d18O_sw = X(2,:,:);

            % Run the forward model
            d18Oc_posterior = bayfox_forward(SST, d18O_sw, obj.species);

            % Get the mean and variance from the posterior
            d18Oc = mean(d18Oc_posterior, 2);
            R = var(d18Oc_posterior, [], 2);

            % Reshape to 1 x nMembers x nEvolving
            [nMembers, nEvolving] = size(SST, 2:3);
            d18Oc = reshape(d18Oc, 1, nMembers, nEvolving);
            R = reshape(R, 1, nMembers, nEvolving);
        end
    end
end