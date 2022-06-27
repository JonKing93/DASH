classdef vslite < PSM.Interface
    %% PSM.vslite  Implement the Vaganov-Shashkin Lite tree ring model
    % ----------
    %   The VS-Lite forward model uses monthly temperature and
    %   precipitation to model tree ring widths. The model is described in
    %   the paper:
    %
    %   Tolwinski-Ward, S. E., Evans, M. N., Hughes, M. K., and 
    %   Anchukaitis, K.J. (2011) An efficient forward model of the climate 
    %   controls on interannual variation in tree-ring width, Clim. Dynam.,
    %   36, 2419–2439.
    %   DOI:  
    %
    %   Github Repository:  https://github.com/suztolwinskiward/VSLite
    % ----------
    % vslite Methods:
    %
    % **ALL USER METHODS**
    %
    %
    % Create:
    %   vslite      - Creates a new VS-Lite PSM object
    %   label       - Apply a label to a VS-Lite object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold VS-Lite temperature and precipitation inputs
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates tree ring width values using monthly temperature and precipitation
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %
    % <a href="matlab:dash.doc('PSM.vslite')">Documentation Page</a>

    % Description and repository
    properties (Constant)
        estimatesR = false;                                     % VS-Lite cannot estimate R uncertainties
        description = "Vaganov-Shashkin Lite tree ring model";  % Description of the PSM
        repository = "suztolwinskiward/VSLite";                 % Github repository for the PSM
        commit = "f86cc33ee0eb9a2b9818994542d3c4179e618631";    % The commit hash of the supported version
        commitComment = "";                                     % Details about the commit
    end

    % Forward model parameters
    properties (SetAccess = private)
        phi;        % Latitude of the tree ring site (decimal degrees north)
        T1;         % Lower temperature threshold (Celsius)
        T2;         % Upper temperature threshold (Celsius)
        M1;         % Lower soil moisture threshold (v/v)
        M2;         % Upper soil moisture threshold (v/v)
        options;    % Optional arguments to the VS-Lite model
    end

    methods
        function[obj] = vslite(phi, T1, T2, M1, M2, options)
            %% PSM.vslite.vslite  Creates a new VSLite PSM object
            % ----------
            %   obj = PSM.vslite(phi, T1, T2, M1, M2)
            %   Initializes a new VS-Lite PSM object. Please see the
            %   documentatation of "VSLite_v2_3.m" in the VSLite repository
            %   for details about the inputs.
            %
            %   obj = PSM.vslite(phi, T1, T2, M1, M2, options)
            %   Provide optional arguments to the VS-Lite model.
            % ----------
            %   Inputs:
            %       phi (numeric scalar): The latitude of the tree-ring 
            %           site in decimal degrees
            %       T1 (numeric scalar): Lower temperature threshold below
            %           which growth is 0. (Celsius)
            %       T2 (numeric scalar): Upper temperature threshold above
            %           which growth is 1. (Celsius)
            %       M1 (numeric scalar): Lower soil moisture threshold
            %           below which growth is 0. (v/v)
            %       M2 (numeric scalar): Upper soil moisture threshold
            %           above which growth is 1. (v/v)
            %       options (cell vector): Optional arguments for the VS-Lite model
            %
            %   Outputs:
            %       obj (scalar PSM.vslite object): The new VS-Lite PSM object
            %
            % <a href="matlab:dash.doc('PSM.vslite.vslite')">Documentation Page</a>

            % Error check
            header = "DASH:PSM:vslite";
            dash.assert.scalarType(phi, 'numeric', 'phi', header);
            dash.assert.scalarType(T1, 'numeric', 'T1', header);
            dash.assert.scalarType(T2, 'numeric', 'T2', header);
            dash.assert.scalarType(M1, 'numeric', 'M1', header);
            dash.assert.scalarType(M2, 'numeric', 'M2', header);

            % Parse optional arguments
            if ~exist('options','var')
                options = {};
            else
                dash.assert.vectorTypeN(options, 'cell', [], 'options', header);
            end

            % Record parameters
            obj.phi = phi;
            obj.T1 = T1;
            obj.T2 = T2;
            obj.M1 = M1;
            obj.M2 = M2;
            obj.options = options;
        end
        function[output] = rows(obj, rows)
            %% PSM.vslite.rows  Indicate the stateVector rows used to run a VS-Lite PSM
            % ----------
            %   obj = obj.rows(rows)
            %   Indicate the state vector rows that should be used as the monthly
            %   temperature and monthly precipitation inputs to the VS-Lite PSM. The
            %   input is a column vector with 24 elements. The first 12 elements should
            %   be monthly temperatures from January to December (in that order). The
            %   last 12 elements should be monthly temperatures from January to
            %   December (also in that order).
            %
            %   obj = obj.rows(memberRows)
            %   Indicate which state vector row to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with 24 rows and one element
            %   per ensemble member. The 24 rows should correspond to the climate
            %   variables described in the previous syntax.
            % 
            %   obj = obj.rows(evolvingRows)
            %   Indicate which state vector row to use for different  ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [24 x 1 x nEvolving] or of size 
            %   [24 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same row for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use a different row for each ensemble member in each evolving ensemble.
            %
            %   rows = obj.rows
            %   Returns the current rows for the PSM object
            %
            %   obj = obj.rows('delete')
            %   Deletes any currently specified rows from the VS-Lite PSM object.
            % ----------
            %   Inputs:
            %       row (column vector, linear indices [24 x 1]): The state vector rows that
            %           hold the monthly temperature and precipitation inputs required
            %           to run the VS-Lite PSM. The first 12 rows are monthly
            %           temperatures from January to December (in that order). The last
            %           12 rows are monthly precipitation from January to December
            %           (also in that order).
            %       memberRows (matrix, linear indices [24 x nMembers]): Indicates
            %           which state vector row to use for each ensemble member. Should
            %           be a matrix with 24 rows (the monthly temperature and precipitation
            %           inputs), and one element per ensemble member. Uses the same rows
            %           for the ensemble members in different evolving ensembles.
            %       evolvingRows (3D array, linear indices [24 x 1|nMembers x nEvolving]):
            %           Indicates which state vector rows to use for different ensembles
            %           in an evolving set. Should be a 3D array, and the number of
            %           elements along the third dimension should match the number of
            %           ensembles in the evolving set. If the second dimension has a
            %           length of 1, uses the same rows for all the ensemble members in
            %           each evolving ensemble. If the second dimension has a length
            %           equal to the number of ensemble members, allows you to indicate
            %           which state vector rows to use for each ensemble member in each
            %           evolving ensemble.
            %
            %   Outputs:
            %       obj (scalar vslite object): The VS-Lite PSM with updated rows
            %       rows (linear indices, [24 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the VS-Lite PSM.
            %
            % <a href="matlab:dash.doc('PSM.vslite.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                inputs = {rows, 24};
            end
            output = obj.parseRows(inputs{:});
            
        end
        function[TRW] = estimate(obj, X)
            %% PSM.vslite.estimate  Estimates tree-ring widths from monthly temperatures and precipitation
            % ----------
            %   TRW = obj.estimate(X)
            %   Runs the VS-Lite forward model on monthly temperatures and
            %   precipitation extracted from a state vector ensemble.
            % ----------
            %   Inputs:
            %       X (numeric array [24 x nMembers x nEvolving]): The monthly
            %           temperatures and precipitations used as inputs to the VS-Lite
            %           PSM. The first 12 rows should be temperatures from January to
            %           Decmember (in that order). The last 12 rows are temperatures
            %           from January to December (also in that order).
            %
            %   Outputs:
            %       TRW (numeric matrix [1 x nMembers x nEvolving]): Tree ring widths
            %           generated from monthly temperatures and precipitations using
            %           the VS-Lite forward model
            % 
            % <a href="matlab:dash.doc('PSM.vslite.estimate')">Documentation Page</a>

            % Split apart the climate inputs
            T = X( 1:12, :, :);
            P = X(13:24, :, :);

            % Preallocate outputs for each evolving ensemble
            [nMembers, nEvolving] = size(T, 2:3);
            TRW = NaN(1, nMembers, nEvolving);

            % Get time constants for model
            syear = 1;
            eyear = nMembers;

            % Run the forward model for each ensemble
            for k = 1:nEvolving
                TRW(:,:,k) = VSLite_v2_3(...
                    syear, eyear, obj.phi, obj.T1, obj.T2, obj.M1, obj.M2, ...
                    T, P, obj.options{:});
            end
        end
    end
end