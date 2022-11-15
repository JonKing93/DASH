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
        d18Osw;     % A fixed d18Osw value in VSMOW
        sst;        % A fixed SST value in Celsius
    end

    methods
        function[obj] = bayfox(species, varargin)
            %% PSM.bayfox.bayfox  Creates a new BayFOX PSM object
            % ----------
            %   obj = <strong>PSM.bayfox</strong>(species)
            %   Initializes a new BayFOX PSM object for a particular
            %   foraminiferal species. The PSM will require both SST and
            %   d18Osw inputs from the state vector ensemble. 
            % 
            %   obj = <strong>PSM.bayfox</strong>(species, 'd18O', d18Osw)
            %   Uses a fixed value of d18O when running the model. The PSM
            %   will only require SST inputs from the state vector ensemble.
            % 
            %   obj = <strong>PSM.bayfox</strong>(species, 'SST', sst)
            %   Uses a fixed SST value when running the model. The PSM will
            %   only require d18Osw inputs from the state vector ensemble.
            % ----------
            %   Inputs:
            %       species (string scalar): Name of the target species.
            %           Please see the documentation of the "bayfox_forward.m" function
            %           in the "bayfoxm" repository for valid species strings
            %       d18Osw (numeric scalar): A fixed d18O_sea-water value (in VSMOW) to use
            %           when running the PSM
            %       sst (numeric scalar): A fixed SST value (in Celsius) to
            %           use when running the PSM
            %
            %   Outputs:
            %       obj (scalar PSM.bayfox object): The new BayFOX PSM object
            %
            % <a href="matlab:dash.doc('PSM.bayfox.bayfox')">Documentation Page</a>
            
            % Error check
            header = "DASH:PSM:bayfox";
            dash.assert.strflag(species, 'species', header);

            % Error check fixed values
            [d18Osw, sst] = dash.parse.nameValue(varargin, ["d18O", "sst"], {[],[]}, 1, header);
            if ~isempty(d18Osw) && ~isempty(sst)
                id = sprintf('%s:allVariablesFixed', header);
                error(id, 'You cannot use a fixed value for both d18Osw and SST. At least one variable must vary across the ensemble.');
            elseif ~isempty(d18Osw)
                dash.assert.scalarType(d18Osw, 'numeric', 'd18Osw', header);
            elseif ~isempty(sst)
                dash.assert.scalarType(sst, 'numeric', 'sst', header);
            end

            % Record parameters
            obj.species = species;
            obj.d18Osw = d18Osw;
            obj.sst = sst;
        end
        function[output] = rows(obj, rows)
            %% PSM.bayfox.rows  Indicate the stateVector rows used to run a BayFOX PSM
            % ----------
            %   obj = <strong>obj.rows</strong>(rows)
            %   Indicate the state vector rows that should be used as input
            %   for the BayFOX PSM when calling "PSM.estimate". By default,
            %   the input should be a column vector with two element. The first element is
            %   the row of the SST input, and the second element is the row
            %   of the d18O (seawater) input.
            %
            %   If you provided a fixed value of d18Osw, then the input
            %   should be scalar and should indicate the row of the SST
            %   input. Similarly, if you provided a fixed SST value, then
            %   the input should be scalar and should indicate the row of
            %   the d18Osw input.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with either 1 row (when there
            %   is fixed d18O or SST), or 2 rows  (when neither variable is fixed)
            %   and one column per ensemble member. If the matrix has two
            %   rows, the the first row indicates SST inputs, and the second
            %   row is the d18O (seawater) inputs.
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   Indicate which state vector row to use for different  ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [1|2 x 1 x nEvolving] or of size 
            %   [1|2 x nMembers x nEvolving]. If the second dimension has a size of 1,
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
            %       rows (column vector, linear indices [1|2]): The state vector rows
            %           required to run the PSM. If either d18Osw or SST is fixed,
            %           then rows is a scalar and indicates the state vector row 
            %           holding the unfixed input. If neither variable is fixed, 
            %           then rows is a column vector with two elements. The
            %           first element is the row of the SST inputs and the second
            %           element is the row of the d18O_seawater inputs.
            %       memberRows (matrix, linear indices [1|2 x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
            %           be a matrix with one (fixed d18O or SST) or two rows (neither variable fixed)
            %           and one column per ensemble member. If using two rows,  
            %           the first row is the SST inputs, and the second row is the
            %           d18O_seawater inputs.
            %       evolvingRows (3D array, linear indices [1|2 x 1|nMembers x nEvolving]):
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
            %       rows (linear indices, [1|2 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the BayFOX PSM.
            %
            % <a href="matlab:dash.doc('PSM.bayfox.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                if isempty(obj.d18Osw) && isempty(obj.sst)
                    nRows = 2;
                else
                    nRows = 1;
                end
                inputs = {rows, nRows};
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
            %       X (numeric array [1|2 x nMembers x nEvolving]):
            %           Sea surface temperatures and/or d18O_seawater values
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
            if isempty(obj.d18Osw) && isempty(obj.sst)
                SST = X(1,:,:);
                d18O_sw = X(2,:,:);
            elseif ~isempty(obj.d18Osw)
                SST = X;
                d18O_sw = obj.d18Osw;
            else
                SST = obj.sst;
                d18O_sw = X;
            end

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