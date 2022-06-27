classdef cellulose < PSM.prysm
    %% PSM.prysm.cellulose  Implement the cellulose sensor module of the PRYSM package
    % ----------
    %   This PSM implements the cellulose sensor module from the PRYSM
    %   Python package. The package is described in the paper:
    %
    %   Dee, S. G., Russell, J. M., Morrill, C., Chen, Z., & Neary, A. 
    %   (2018). PRYSM v2. 0: A proxy system model for lacustrine archives. 
    %   Paleoceanography and Paleoclimatology, 33(11), 1250-1269.
    %   DOI:
    %
    %   Github Repository: https://github.com/sylvia-dee/PRYSM
    %
    %   Prerequisites: Python 3.4, numpy, scipy, and rpy2. See the PRYSM
    %       docoumentation for additional details.
    % ----------
    % cellulose Methods:
    %
    % **ALL USER METHODS**
    %
    % Create:
    %   cellulose   - Creates a new PRYSM cellulose object
    %   label       - Apply a label to a PRYSM cellulose object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold cellulose sensor module inputs
    %   
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates cellulose d18O values from T, P, and RH extracted from a state vector ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %
    % <a href="matlab:dash.doc('PSM.prysm.cellulose')">Documentation Page</a>

    % Description
    properties (Constant)
        description = ... Description of the PSM
            "Cellulose sensor module from the PRYSM Python package";
    end

    % Forward model parameters
    properties (SetAccess = private)
        d18Os;
        d18Op;
        d18Ov;
        flag;
        iso;
    end

    methods
        function[obj] = cellulose(d18Os, d18Op, d18Ov, flag, iso)
            %% PSM.prysm.cellulose  Create a new PRYSM Cellulose PSM object
            % ----------
            %   obj = PSM.prysm.cellulose(d18Os, d18Op, d18Ov, flag, iso)
            %   Creates a new PSM object that implements the PRYSM
            %   cellulose sensor module. Please see the documentation of
            %   the "cellulose_sensor.py" function in the
            %   psm.cellulose.senosr module of the PRYSM Python package for
            %   details about the inputs.
            % ----------
            %   Inputs:
            %       d18Os (numeric scalar): Isotope ratio of soil water
            %       d18Op (numeric scalar): Isotope ratio of precipitation
            %       d18Ov (numeric scalar): Isotope ratio of ambient vapor
            %           at surface layer
            %       flag (numeric scalar): Flag for the type of cellulose model 
            %       iso (scalar logical): Whether to use isotope-ensabled model 
            %           output (true) or not (false).
            %
            %   Outputs:
            %       obj (scalar prysm.cellulose object): The new PRYSM
            %           cellulose PSM object
            %
            % <a href="matlab:dash.doc('PSM.prysm.cellulose.cellulose')">Documentation Page</a>

            % Error check
            header = "DASH:PSM:prysm:cellulose";
            dash.assert.scalarType('d18Os', 'numeric', 'd18Os', header);
            dash.assert.scalarType('d18Op', 'numeric', 'd18Op', header);
            dash.assert.scalarType('d18Ov', 'numeric', 'd18Ov', header);
            dash.assert.scalarType('flag', 'numeric', 'flag', header);
            dash.assert.scalarType('iso', 'logical', 'iso', header);

            % Record parameters
            obj.d18Os = d18Os;
            obj.d18Op = d18Op;
            obj.d18Ov = d18Ov;
            obj.flag = flag;
            obj.iso = iso;
        end
        function[output] = rows(obj, rows)
            %% PSM.prysm.cellulose.rows  Indicate the stateVector rows used to run the PRYSM cellulose sensor module
            % ----------
            %   obj = obj.rows(rows)
            %   Indicate the state vectors row that should be used as the 
            %   temperature, precipitaion, and relative humidity inputs
            %   for the cellulose sensor module when calling the "PSM.estimate"
            %   command. The input is a column vector with 3 rows. The first
            %   row is temperature, second is precipitation, third is
            %   relative humidity. Uses the same state vector rows for each
            %   ensemble member and each ensemble in an evolving set.
            %
            %   obj = obj.rows(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with 3 rows, and one
            %   column per ensemble member. The rows should refer to the
            %   temperature, precipitation, and relative humidity variables
            %   (in that order).
            %
            %   obj = obj.rows(evolvingRows)
            %   This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [3 x 1 x nEvolving] or of size 
            %   [3 x nMembers x nEvolving]. If the second dimension has a size of 1,
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
            %       rows (linear indices, column vector [3]): The state vector rows that hold
            %           the climate variables required to run the cellulose sensor module.
            %           The first row is temperature, second is precipitation, and third
            %           is relative humidity. Uses the same rows for
            %           all ensemble members and ensembles in an evolving set.
            %       memberRows (row vector, linear indices [3 x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
            %           be a matrix with 3 rows and one element per ensemble member. Uses
            %           the same rows for the ensemble members in different evolving ensembles.
            %       evolvingRows (3D array, linear indices [3 x 1|nMembers x nEvolving]):
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
            %       obj (scalar prysm.cellulose object): The cellulose PSM with updated rows
            %       rows (linear indices, [1 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the cellulose PSM
            %
            % <a href="matlab:dash.doc('PSM.prysm.cellulose.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                inputs = {rows, 1};
            end
            output = obj.parseRows(inputs{:});
        end
        function[d18O] = estimate(obj, X)
            %% PSM.prysm.cellulose.estimate  Estimates cellulose d18O values from T, P, and RH
            % ----------
            %   d18O = obj.estimate(X)
            %   Runs the PRYSM cellulose sensor module on a set of
            %   temperatures, precipitations, and relative humidities
            %   extracted from a state vector ensemble. Estimate d18O
            %   values of cellulose.
            % ----------
            %   Inputs:
            %       X (numeric array [3 x nMembers x nEvolving]): The
            %           temperature, precipitation, and relative humidity
            %           inputs used to run the PRYSM cellulose sensor module.
            %           The first row is temperature, second row is
            %           precipitation, and third row is relative humidity.
            %
            %   Outputs:
            %       d18O (numeric matrix [1 x nMembers x nEvolving]):
            %           Cellulose d18O estimates produced using the PRYSM
            %           cellulose sensor module.
            %
            % <a href="matlab:dash.doc('PSM.prysm.cellulose.estimate')">Documentation Page</a>

            % Split the variables
            T  = X(1,:,:);
            P  = X(2,:,:);
            RH = X(3,:,:);

            % Preallocate outputs for each evolving ensemble
            [nMembers, nEvolving] = size(T, 2:3);
            d18O = NaN(1, nMembers, nEvolving);

            % Get time placeholder as numpy array
            time = 1:nMembers;
            time = py.numpy.array(time);

            % For each evolving ensemble, convert variables to numpy arrays
            for k = 1:nEvolving
                Tpy = py.numpy.array(T(:,:,k));
                Ppy = py.numpy.array(P(:,:,k));
                RHpy = py.numpy.array(RH(:,:,k));

                % Run the forward model. Convert output back to Matlab
                d18Opy = py.psm.cellulose.sensor.cellulose_sensor(...
                    time, Tpy, Ppy, RHpy, obj.d18Os, obj.d18Op, obj.d18Ov, ...
                    obj.flag, obj.iso);
                d18O(:,:,k) = numeric(d18Opy);
            end
        end
    end

end
