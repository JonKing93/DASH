classdef baymag < PSM.Interface
    %% PSM.baymag  Implements BayMAG, a Bayesian forward model for Mg/Ca of planktic foraminifera
    % ----------
    %   The BayMAG PSM is a Bayesian forward model that estimates the Mg/Ca
    %   ratios of planktic foraminifera. The forward model is described in
    %   the paper:
    %
    %   Tierney, J. E., Malevich, S. B., Gray, W., Vetter, L., and
    %   Thirumalai, K. (2019)  Bayesian calibration of the Mg/Ca paleothermometer
    %   in planktic foraminifera. Paleoceanography and Paleoclimatology, 
    %   34(12), 2005-2030
    %   DOI:  https://doi.org/10.1029/2019PA003744
    %   
    %   Github Repository:  https://github.com/jesstierney/BAYMAG
    % ----------
    % baymag Methods:
    %
    % *ALL USER METHODS*
    %
    % Create:
    %   baymag      - Creates a new BayMAG PSM object
    %   label       - Apply a label to a BayMAG object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold BayMAG SST inputs
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates Mg/Ca ratios from SST values extracted from an ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.baymag')">Documentation Page</a>

    % Description and repository
    properties (Constant)
        estimatesR = true;                                                  % The BayMAG PSM can estimate R uncertainties
        description = "Bayesian model for Mg/Ca of planktic foraminifera";  % Description of the BayMAG PSM
        hasMemory = false;                                                  % No memory of previous time steps
        
        repository = "jesstierney/BAYMAG";                                  % Github repository holding the BayMAG PSM
        commit = "635490f13b5de3d44d32274a689b77c101d2aa4e";                % Commit hash of the supported version of the PS<
        commitComment = "Version 1.1";               % Details about the supported commit
    end

    % Forward model parameters
    properties (SetAccess = private)
        age;        % Ages
        clean;      % Cleaning technique, between 0-fully oxidative and 1-fully reductive
        species;    % Name of target specifies
        options;    % Optional arguments

        sst;        % Sea surface temperature (Celsius)
        salinity;   % Sea surface salinity (psu)
        omega;      % Bottom water saturation state
        pH;         % pH (total scale)
    end

    methods
        function[obj] = baymag(age, clean, species, varargin)
            %% PSM.baymag.baymag  Creates a new BayMAG PSM object
            % ----------
            %   obj = <strong>PSM.baymag</strong>(age, clean, species)
            %   Initializes a new BayMAG PSM object. The PSM will require
            %   SST, SSS, Omega, and pH inputs from the ensemble. Please see the
            %   documentation of baymag_forward_ln.m in the BayMAG
            %   repository for details about the inputs.
            %
            %   obj = <strong>PSM.baymag</strong>(..., 'options', options)
            %   Provide optional arguments to the BayMAG forward model. See
            %   the documentation of baymag_forward_ln.m in the BayMAG
            %   repository for details.
            %
            %   obj = PSM.baymag(..., 'pH', pH)
            %   Uses a fixed value for pH, rather than values from the
            %   ensemble.
            %
            %   obj = PSM.baymag(..., 'omega', omega)
            %   Uses a fixed value for Omega, rather than values from the
            %   ensemble.
            %
            %   obj = PSM.baymag(..., 'salinity', salinity)
            %   Uses a fixed value for sea-surface salinity, rather than
            %   values from the ensemble.
            %
            %   obj = PSM.baymag(..., 'sst', sst)
            %   Uses a fixed value for sea-surface temperatures, rather
            %   than values from the ensemble.
            % ----------
            %   Inputs:
            %       age (numeric scalar): Age of the observation
            %       clean (numeric scalar): Describes the cleaning technique
            %       species (string scalar): Name of the target species. 
            %       options (cell vector): Optional arguments for the BayMAG PSM
            %       pH (numeric scalar): pH (total scale)
            %       omega (numeric scalar): Bottom water saturation state
            %       salinity (numeric scalar): Sea surface salinity (in psu)
            %       sst (numeric scalar): Sea surface temperature (Celsius)
            %
            %   Outputs:
            %       obj (scalar PSM.baymag object): The new BayMAG PSM object
            %
            % <a href="matlab:dash.doc('PSM.baymag.baymag')">Documentation Page</a>
            
            % Error check
            header = "DASH:PSM:baymag";
            dash.assert.scalarType(age, 'numeric', 'age', header);
            dash.assert.scalarType(clean, 'numeric', 'clean', header);
            dash.assert.strflag(species, 'species', header);

            % Check optional arguments
            [options, pH, omega, salinity, sst] = dash.parse.nameValue(varargin, ...
                ["options","pH","omega","salinity","sst"], {{},[],[],[],[]}, 3, header);
            if ~isempty(options)
                dash.assert.vectorTypeN(options, 'cell', [], 'options', header);
            end
            if ~isempty(pH) && ~isempty(omega) && ~isempty(salinity) && ~isempty(sst)
                id = sprintf('%s:allVariablesFixed', header);
                error(id, 'You cannot fix all of pH, omega, salinity, and sst. At least one variable must vary across the ensemble.');
            end
            if ~isempty(pH)
                dash.assert.scalarType(pH, 'numeric', 'pH', header);
            end
            if ~isempty(omega)
                dash.assert.scalarType(omega, 'numeric', 'omega', header);
            end
            if ~isempty(salinity)
                dash.assert.scalarType(salinity, 'numeric', 'salinity', header);
            end
            if ~isempty(sst)
                dash.assert.scalarType(sst, 'numeric', 'sst', header);
            end

            % Record parameters
            obj.age = age;
            obj.clean = clean;
            obj.species = species;
            obj.options = options;
            obj.pH = pH;
            obj.omega = omega;
            obj.salinity = salinity;
            obj.sst = sst;
        end
        function[output] = rows(obj, rows)
            %% PSM.baymag.rows  Indicate the stateVector rows used to run a BayMAG PSM
            % ----------
            %   obj = <strong>obj.rows</strong>(row)
            %   Indicate the state vector row that should be used as the SST
            %   input for the BayMAG PSM when calling the "PSM.estimate"
            %   command. The input is a column vector with one element per
            %   climate variable that varies across the ensemble. The order
            %   of rows should be SST, SSS, Omega, and pH, excluding any 
            %   variables that are fixed. Uses the same state vector
            %   row for each ensemble member and each ensemble in an
            %   evolving set.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with one column per
            %   ensemble member, and one row per climate variable that varies across
            %   the ensemble. The order of rows should be SST, SSS, Omega, and pH, excluding any 
            %   variables that are fixed.
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   Indicate which state vector row to use for different  ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [1-4 x 1 x nEvolving] or of size 
            %   [1-4 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same row for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use a different row for each ensemble member in each evolving ensemble.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows for the PSM object
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any currently specified rows from the BayMAG PSM object.
            % ----------
            %   Inputs:
            %       row (column vector, linear indices [1-4]): The state vector row that holds the 
            %           climate variables required to run the BayMAG PSM. Uses the same row for
            %           all ensemble members and ensembles in an evolving
            %           set. The order of rows should be SST, SSS, omega,
            %           and pH, excluding any variables that are fixed.
            %       memberRows (matrix, linear indices [1-4 x nMembers]): Indicates
            %           which state vector row to use for each ensemble member. Should
            %           be a matrix with one column per ensemble member, and one row
            %           per variable. The order of rows should be SST, SSS, Omega, and pH,
            %           excluding any variables that are fixed. Uses the same rows for the 
            %           ensemble members in different evolving ensembles.
            %       evolvingRows (3D array, linear indices [1-4 x 1|nMembers x nEvolving]):
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
            %       obj (scalar baymag object): The BayMAG PSM with updated rows
            %       rows (linear indices, [1-4 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the BayMAG PSM.
            %
            % <a href="matlab:dash.doc('PSM.baymag.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                nRows = 0;
                variables = ["pH","omega","salinity","sst"];
                for v = 1:numel(variables)
                    if isempty(obj.(variables(v)))
                        nRows = nRows + 1;
                    end
                end
                inputs = {rows, nRows};
            end
            output = obj.parseRows(inputs{:});
        end
        function[MgCa, R] = estimate(obj, X)
            %% PSM.baymag.estimate  Estimates Mg/Ca values from sea surface temperatures
            % ----------
            %   [MgCa, R] = <strong>obj.estimate</strong>(X)
            %   Runs the BayMAG forward model on data extracted from a state
            %   vector ensemble. Returns an estimate of Mg/Ca values and 
            %   optionally estimates uncertainties for the estimated values.
            % ----------
            %   Inputs:
            %       X (numeric array [1-4 x nMembers x nEvolving]):
            %           Sea surface temperatures, sea surface salinities,
            %           omegas, and/or pH inputs required to run the BayMAG PSM.
            %
            %   Outputs:
            %       MgCa (numeric matrix [1 x nMembers x nEvolving]): Mg/Ca
            %           estimates generated from the SST values using the
            %           BayMAG forward model.
            %       R (numeric matrix [1 x nMembers x nEvolving]): Uncertainty
            %           estimates for each Mg/Ca value.
            %
            % <a href="matlab:dash.doc('PSM.baymag.estimate')">Documentation Page</a>

            % Iterate through climate variable properties
            variables = ["sst","salinity","omega","pH"];
            values = cell(1,4);
            row = 1;
            for v = 1:numel(variables)
                variable = variables(v);

                % Either extract from the ensemble
                if isempty(obj.(variable))
                    values{v} = X(row,:);
                    row = row+1;

                % Or use fixed value
                else
                    values{v} = obj.(variable);
                end
            end
            [sst, salinity, omega, pH] = values{:}; %#ok<*PROPLC> 

            % Run the forward model
            mgcaPosterior = baymag_forward_ln(...
                obj.age, sst, omega, salinity, pH, obj.clean, ...
                obj.species, obj.options{:});

            % Get the mean and variance from the posterior
            MgCa = mean(mgcaPosterior, 2);
            R = var(mgcaPosterior, [], 2);

            % Reshape to 1 x nMembers x nEvolving
            [nMembers, nEvolving] = size(X, 2:3);
            MgCa = reshape(MgCa, 1, nMembers, nEvolving);
            R = reshape(R, 1, nMembers, nEvolving);
        end
    end
end