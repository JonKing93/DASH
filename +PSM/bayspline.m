classdef bayspline < PSM.Interface
    %% PSM.bayspline  Implements the BaySpline PSM, a Baysian forward model for UK'37
    % ----------
    %   The BaySpline PSM is a Bayesian forward model that estimates UK'37
    %   values from sea-surface temperatures. The forward model is
    %   described in the paper:
    %
    %   Tierney, J.E. & Tingley, M.P. (2018) BAYSPLINE: A New Calibration for
    %   the Alkenone Paleothermometer. Paleoceanography and 
    %   Paleoclimatology 33, 281-301.
    %   DOI: http://doi.org/10.1002/2017PA003201
    %
    %   Github Repository: https://github.com/jesstierney/BAYSPLINE
    %
    %   Prerequisites: Requires Matlab's Curve Fitting Toolbox
    % ----------
    % bayspline Methods:
    %
    % **ALL USER METHODS**
    %
    % Create:
    %   bayspline   - Creates a new BaySpline PSM object
    %   label       - Apply a label to a BaySpline object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold BaySpline SST inputs
    %   
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates UK37 values from SST values extracted from an ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.bayspline')">Documentation Page</a>

    % Information about the forward model codebase
    properties (Constant, Hidden)
        estimatesR = true;                                      % The BaySpline PSM can estimate R uncertainties       
        description = "Baysian model for UK'37";                % Description of the PSM
        repository = "jesstierney/BAYSPLINE";                   % Github Repository holding the PSM
        commit = "1e6f9673bcc55b483422c6d6e1b1f63148636094";    % The Github commit of the PSM that is supported by DASH
        commitComment = "Most recent as of Jan. 1, 2021. Code updated November 24, 2020";  % Details about the supported commit
    end

    % Forward model parameters
    properties (SetAccess = private)
        bayes = {};     % Name of the file holding the Bayesian posterior for calibration
    end

    methods
        function[obj] = bayspline(bayesFile)
            %% PSM.bayspline.bayspline  Creates a new BaySpline PSM object
            % ----------
            %   obj = PSM.bayspline
            %   Initializes a new BaySpline PSM object.
            %
            %   obj = PSM.bayspline(bayesFile)
            %   Optionally specifies a file to use as the Bayesian
            %   posterior for the calibration.
            % ----------
            %   Inputs:
            %       bayesFile (string scalar): The name of the file to use
            %           as the Bayesian posterior for the calibration.
            %
            %   Outputs:
            %       obj (scalar PSM.bayspline object): The new BaySpline PSM object
            %
            % <a href="matlab:dash.doc('PSM.bayspline.bayspline')">Documentation Page</a>

            if exist('bayesFile','var')
                header = "DASH:PSM:bayspline";
                obj.bayes = {dash.assert.strflag(bayesFile, 'bayesFile', header)};
            end

        end
        function[output] = rows(obj, rows)
            %% PSM.bayspline.rows  Indicate the stateVector rows used to run a BaySpline PSM
            % ----------
            %   obj = obj.rows(row)
            %   Indicate the state vector row that should be used as the SST
            %   input for the BaySpline PSM when calling the "PSM.estimate"
            %   command. The input is a scalar. Uses the same state vector
            %   row for each ensemble member and each ensemble in an
            %   evolving set.
            %
            %   obj = obj.rows(memberRows)
            %   Indicate which state vector row to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a row vector with one element per
            %   ensemble member.
            %
            %   obj = obj.rows(evolvingRows)
            %   Indicate which state vector row to use for different  ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [1 x 1 x nEvolving] or of size 
            %   [1 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same row for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use a different row for each ensemble member in each evolving ensemble.
            %
            %   rows = obj.rows
            %   Returns the current rows for the PSM object
            %
            %   obj = obj.rows('delete')
            %   Deletes any currently specified rows from the BaySpline PSM object.
            % ----------
            %   Inputs:
            %       row (scalar linear index): The state vector row that holds the SST
            %           input required to run the BaySpline PSM. Uses the same row for
            %           all ensemble members and ensembles in an evolving set.
            %       memberRows (row vector, linear indices [1 x nMembers]): Indicates
            %           which state vector row to use for each ensemble member. Should
            %           be a row vector with one element per ensemble member. Uses
            %           the same rows for the ensemble members in different evolving ensembles.
            %       evolvingRows (3D array, linear indices [1 x 1|nMembers x nEvolving]):
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
            %       obj (scalar bayspline object): The BaySpline PSM with updated rows
            %       rows (linear indices, [1 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the BaySpline PSM.
            %
            % <a href="matlab:dash.doc('PSM.bayspline.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                inputs = {rows, 1};
            end
            output = obj.parseRows(inputs{:});
        end
        function[UK37, R] = estimate(obj, SST)
            %% PSM.bayspline.estimate  Estimates UK37 values from sea surface temperatures
            % ----------
            %   [UK37, R] = obj.estimate(SST)
            %   Runs the BaySpline forward model on a set of SSTs. Returns
            %   an estimate of UK37 values and optionally estimates
            %   uncertainties for the estimated values.
            % ----------
            %   Inputs:
            %       SST (numeric array [1 x nMembers x nEvolving]):
            %           Sea surface temperatures used as input for the
            %           BaySpline PSM.
            %
            %   Outputs:
            %       UK37 (numeric matrix [1 x nMembers x nEvolving]): UK37
            %           estimates generated from the SST values using the
            %           BaySpline forward model.
            %       R (numeric matrix [1 x nMembers x nEvolving]): Uncertainty
            %           estimates for each UK37 value.
            %
            % <a href="matlab:dash.doc('PSM.bayspline.estimate')">Documentation Page</a>

            % Run the forward model
            ukPosterior = UK_forward(SST, obj.bayes{:});

            % Use the mean and variance of the posterior
            UK37 = mean(ukPosterior, 2);
            R = var(ukPosterior, [], 2);

            % Reshape to 1 x nMembers x nEvolving
            [nMembers, nEvolving] = size(SST, 2:3);
            UK37 = reshape(UK37, 1, nMembers, nEvolving);
            R = reshape(R, 1, nMembers, nEvolving);
        end
    end

end