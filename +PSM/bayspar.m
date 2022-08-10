classdef bayspar < PSM.Interface
    %% PSM.bayspar  Implements the BaySPAR PSM, a Bayesian forward model for TEX86
    % ----------
    %   The BaySPAR PSM is a Bayesian forward model that estimates TEX86
    %   values from sea-surface temperatures. The forward model is
    %   described in the paper:
    %
    %   Tierney, J.E. & Tingley, M.P. (2014) A Bayesian, spatially-varying 
    %   calibration model for the TEX86 proxy. Geochimica et Cosmochimica 
    %   Acta, 127, 83-106. 
    %   DOI:  https://doi.org/10.1016/j.gca.2013.11.026.
    %
    %   Github Repository:  https://github.com/jesstierney/BAYSPAR
    % ----------
    % bayspar Methods:
    %
    % *ALL USER METHODS*
    %
    % Create:
    %   bayspar     - Creates a new BaySPAR PSM object
    %   label       - Apply a label to a BaySPAR object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold BaySPAR SST inputs
    %   
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates TEX86 values from SST values extracted from an ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.bayspar')">Documentation Page</a>

    % Information about the forward model codebase
    properties (Constant)
        estimatesR = true;                                      % The BaySpline PSM can estimate R uncertainties       
        description = "Baysian model for TEX86";                % Description of the PSM
        repository = "jesstierney/BAYSPAR";                     % Github Repository holding the PSM
        commit = "310e876513151bf01e7c39f5dbdde7b991ea7204";    % The Github commit of the PSM that is supported by DASH
        commitComment = "Most recent as of June 28, 2022. Code updated July 2, 2021";  % Details about the supported commit
    end

    % Forward model parameters
    properties (SetAccess = private)
        latitude;       % The latitude of the proxy site
        longitude;      % The longitude of the proxy site
        options;        % Optional arguments for the forward model
    end

    methods
        function[obj] = bayspar(latitude, longitude, options)
            %% PSM.bayspar.bayspar  Creates a new BaySPAR PSM object
            % ----------
            %   obj = <strong>PSM.bayspar</strong>(latitude, longitude)
            %   Initializes a new BaySPAR PSM object. Please see the
            %   documentation of TEX_forward.m in the BaySPAR repository
            %   for details about the inputs.
            %
            %   obj = <strong>PSM.bayspar</strong>(latitude, longitude, options)
            %   Provide optional arguments to the BaySPAR forward model.
            % ----------
            %   Inputs:
            %       latitude (numeric scalar): The latitude of the proxy
            %           site in decimal degrees.
            %       longitude (numeric scalar): The longitude of the proxy
            %           site in decimal degrees.
            %       options (cell vector): Optional arguments to the
            %           BaySPAR forward model
            %
            %   Outputs:
            %       obj (scalar PSM.bayspar object): The new BaySPAR PSM object
            %
            % <a href="matlab:dash.doc('PSM.bayspar.bayspar')">Documentation Page</a>

            % Error check
            header = "DASH:PSM:bayspar";
            dash.assert.scalarType(latitude, 'numeric', header);
            dash.assert.scalarType(longitude, 'numeric', header);

            % Parse optional inputs
            if ~exist('options', 'var')
                options = {};
            else
                dash.assert.vectorTypeN(options, 'cell', [], 'options', header);
            end

            % Record parameters
            obj.latitude = latitude;
            obj.longitude = longitude;
            obj.options = options;
        end
        function[output] = rows(obj, rows)
            %% PSM.bayspar.rows  Indicate the stateVector rows used to run a BaySPAR PSM
            % ----------
            %   obj = <strong>obj.rows</strong>(row)
            %   Indicate the state vector row that should be used as the SST
            %   input for the BaySPAR PSM when calling the "PSM.estimate"
            %   command. The input is a scalar. Uses the same state vector
            %   row for each ensemble member and each ensemble in an
            %   evolving set.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector row to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a row vector with one element per
            %   ensemble member.
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   Indicate which state vector row to use for different  ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [1 x 1 x nEvolving] or of size 
            %   [1 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same row for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use a different row for each ensemble member in each evolving ensemble.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows for the PSM object
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any currently specified rows from the BaySPAR PSM object.
            % ----------
            %   Inputs:
            %       row (scalar linear index): The state vector row that holds the SST
            %           input required to run the BaySPAR PSM. Uses the same row for
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
            %       obj (scalar bayspar object): The BaySPAR PSM with updated rows
            %       rows (linear indices, [1 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the BaySPAR PSM.
            %
            % <a href="matlab:dash.doc('PSM.bayspar.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                inputs = {rows, 1};
            end
            output = obj.parseRows(inputs{:});
        end
        function[TEX86, R] = estimate(obj, SST)
            %% PSM.bayspar.estimate  Estimates TEX86 values from sea surface temperatures
            % ----------
            %   [TEX86, R] = <strong>obj.estimate</strong>(SST)
            %   Runs the BaySPAR forward model on a set of SSTs. Returns
            %   an estimate of TEX86 values and optionally estimates
            %   uncertainties for the estimated values.
            % ----------
            %   Inputs:
            %       SST (numeric array [1 x nMembers x nEvolving]):
            %           Sea surface temperatures used as input for the
            %           BaySPAR PSM.
            %
            %   Outputs:
            %       TEX86 (numeric matrix [1 x nMembers x nEvolving]): TEX86
            %           estimates generated from the SST values using the
            %           BaySPAR forward model.
            %       R (numeric matrix [1 x nMembers x nEvolving]): Uncertainty
            %           estimates for each TEX86 value.
            %
            % <a href="matlab:dash.doc('PSM.bayspar.estimate')">Documentation Page</a>

            % Run the forward model
            texPosterior = TEX_forward(obj.latitude, obj.longitude, SST, obj.options{:});

            % Get the mean and variance from the posterior
            TEX86 = mean(texPosterior, 2);
            R = var(texPosterior, [], 2);

            % Reshape to 1 x nMembers x nEvolving
            [nMembers, nEvolving] = size(SST, 2:3);
            TEX86 = reshape(TEX86, 1, nMembers, nEvolving);
            R = reshape(R, 1, nMembers, nEvolving);
        end
    end

end