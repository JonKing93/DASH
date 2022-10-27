classdef icecore < PSM.prysm
    %% PSM.prysm.icecore  Implement the icecore sensor module of the PRYSM package
    % ----------
    %   This PSM implements the icecore sensor module from the PRYSM
    %   Python package. The package is described in the paper:
    %
    %   Dee, S. G., Russell, J. M., Morrill, C., Chen, Z., & Neary, A. 
    %   (2018). PRYSM v2. 0: A proxy system model for lacustrine archives. 
    %   Paleoceanography and Paleoclimatology, 33(11), 1250-1269.
    %   DOI:  https://doi.org/10.1029/2018PA003413
    %
    %   Github Repository: https://github.com/sylvia-dee/PRYSM
    %
    %   Prerequisites: Python 3.4, numpy, scipy, and rpy2. See the PRYSM
    %       documentation for additional details.
    % ----------
    % icecore Methods:
    %
    % **ALL USER METHODS**
    %
    % Create:
    %   icecore     - Creates a new PRYSM icecore object
    %   label       - Apply a label to a PRYSM icecore object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold icecore sensor module inputs
    %   
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates precipitation weighted d18O values given d18O inputs extracted from a state vector ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.prysm.icecore')">Documentation Page</a>

    % Description
    properties (Constant)
        description = "Ice-core sensor module from the PRYSM Python package";
    end

    % Forward model parameters
    properties (SetAccess = private)
        alt_diff = 0;   % Actual altitude-model altitude (meters)
    end

    methods
        function[obj] = icecore(alt_diff)
            %% PSM.prysm.icecore  Create a new PRYSM icecore PSM
            % ----------
            %   obj = PSM.prysm.icecore
            %   Creates a new PSM object that implements the PRYSM icecore
            %   sensor module. Runs the model without an altitude correction.
            %   
            %   obj = PSM.prysm.icecore(alt_diff)
            %   Specify an altitude correction (in meters) for the ice core.
            % ----------
            %   Inputs:
            %       alt_diff (numeric scalar): The altitude correction (in meters)
            %
            %   Outputs:
            %       obj (scalar prysm.icecore object): The new PRYSM
            %           icecore PSM object
            %
            % <a href="matlab:dash.doc('PSM.prysm.icecore.icecore')">Documentation Page</a>

            % Error check and record altitude difference
            if exist('alt_diff','var')
                header = "DASH:PSM:prysm:icecore";
                dash.assert.scalarType(alt_diff, 'numeric', 'alt_diff', header);
                obj.alt_diff = alt_diff;
            end

        end
        function[output] = rows(obj, rows)
            %% PSM.prysm.icecore.rows  Indicate the stateVector rows used to run the PRYSM icecore sensor module
            % ----------
            %   obj = obj.rows(row)
            %   Indicate the state vectors row that should be used as the 
            %   d18O inputs for the icecore sensor module when calling the "PSM.estimate"
            %   command. The input is a scalar. Uses the same state vector row for each
            %   ensemble member and each ensemble in an evolving set.
            %
            %   obj = obj.rows(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with 1 row, and one
            %   column per ensemble member.
            %
            %   obj = obj.rows(evolvingRows)
            %   This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [1 x 1 x nEvolving] or of size 
            %   [1 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same rows for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use different rows for each ensemble member in each evolving ensemble.
            %
            %   rows = obj.rows
            %   Returns the current rows for the PSM object
            %
            %   obj = obj.rows('delete')
            %   Deletes any currently specified rows from the object.
            % ----------
            %   Inputs:
            %       row (scalar linear index): The state vector row that hold
            %           the d18O inputs required to run the icecore sensor module.
            %           Uses the same rows for all ensemble members and ensembles in an evolving set.
            %       memberRows (row vector, linear indices [1 x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
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
            %       obj (scalar prysm.icecore object): The icecore PSM with updated rows
            %       rows (linear indices, [1 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the icecore PSM
            %
            % <a href="matlab:dash.doc('PSM.prysm.icecore.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                inputs = {rows, 1};
            end
            output = obj.parseRows(inputs{:});
        end
        function[d18O] = estimate(obj, X)
            %% PSM.prysm.icecore.estimate  Estimates precipitation-weghted d18O for an ice core
            % ----------
            %   d18O = obj.estimate(X)
            %   Runs the PRYSM icecore sensor module on a set of
            %   precipitation d18O values. Estimates precipitation-weighted
            %   d18O values for the ice core.
            % ----------
            %   Inputs:
            %       X (numeric array [1 x nMembers x nEvolving]): The d18O
            %           inputs used to run the PRYSM icecore module.
            %
            %   Outputs:
            %       d18O (numeric matrix [1 x nMembers x nEvolving]):
            %           Precipitation weighted d18O estimates for the
            %           icecore produced using the PRYSM icecore model.
            %
            % <a href="matlab:dash.doc('PSM.prysm.icecore.estimate')">Documentation Page</a>
            
            % Preallocate outputs for evolving ensembles
            [nMembers, nEvolving] = size(T, 2:3);
            d18O = NaN(1, nMembers, nEvolving);

            % Get time placeholder as numpy array
            time = py.numpy.array(0);

            % Convert variables to numpy arrays for each variable
            for k = 1:nEvolving
                Xpy = py.numpy.array(X(:,:,k));

                % Run the model and convert output back to matlab numeric
                d18Opy = py.psm.icecore.sensor.icecore_sensor(...
                            time, Xpy, obj.alt_diff);
                d18O(:,:,k) = numeric(d18Opy);
            end
        end
    end

end