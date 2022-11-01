classdef cellulose < PSM.prysm.package
    %% PSM.prysm.cellulose  Implement the cellulose sensor module of the PRYSM package
    % ----------
    %   This PSM implements the cellulose sensor module from the PRYSM
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
    % cellulose Methods:
    %
    % *ALL USER METHODS*
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
    %   estimate    - Estimates cellulose d18O using variables extracted from a state vector ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.prysm.cellulose')">Documentation Page</a>

    % Description
    properties (Constant)
        description = ... Description of the PSM
            "Cellulose sensor module from the PRYSM Python package";
    end

    % Forward model parameters
    properties (SetAccess = private)
        flag;   % The model to use
        iso;    % Whether to use isotope-enabled model output        
    end

    methods
        function[obj] = cellulose(d18Os, d18Op, d18Ov, varargin)
            %% PSM.prysm.cellulose.cellulose  Create a new PRYSM Cellulose PSM object
            % ----------
            %   obj = <strong>PSM.prysm.cellulose</strong>
            %   Creates a new PSM object that implements the PRYSM
            %   cellulose sensor module. Runs the PSM using isotope-enabled
            %   model output and the Evans et al., 2007 model.
            %
            %   Please see the documentation of the "cellulose_sensor.py" 
            %   function in the psm.cellulose.sensor module of the PRYSM
            %   Python package for additional details about the inputs.
            %
            %   obj = <strong>PSM.prysm.cellulose</strong>(..., 'flag', flag)
            %   Indicate whether to use the Evans et al., 2007 model or the
            %   Roden et al., 2003 model. Default is Evans.
            %
            %   obj = <strong>PSM.prysm.cellulose</strong>(..., 'iso', iso)
            %   Indicate whether to use isotope-enabled model output in the
            %   calculation of dS and dV. Default is to use isotope-enabled output.
            % ----------
            %   Inputs:
            %       flag (0 | 1): Flag for the type of cellulose model
            %           [0]: Roden et al., 2003
            %           [1]: (Deafult) Evans et al., 2007
            %       iso (scalar logical): Whether to use isotope-ensabled model 
            %           output (true) or not (false). Default is true.
            %
            %   Outputs:
            %       obj (scalar prysm.cellulose object): The new PRYSM
            %           cellulose PSM object
            %
            % <a href="matlab:dash.doc('PSM.prysm.cellulose.cellulose')">Documentation Page</a>

            % Error check
            header = "DASH:PSM:prysm:cellulose";
            [flag, iso] = dash.parse.nameValue(varargin, ["flag","iso"], {1, true}, 3, header);
            dash.assert.scalarType(iso, 'logical', 'iso', header);
            if ~ismember(flag, [0 1])
                id = sprintf('%s:invalidFlag', header);
                error(id, 'flag must either be 0 or 1');
            end

            % Record parameters
            obj.flag = flag;
            obj.iso = iso;
        end
        function[output] = rows(obj, rows)
            %% PSM.prysm.cellulose.rows  Indicate the stateVector rows used to run the PRYSM cellulose sensor module
            % ----------
            %   obj = <strong>obj.rows</strong>(rows)
            %   Indicate the state vectors row that should be used as the 
            %   temperature, precipitaion, and relative humidity inputs
            %   for the cellulose sensor module when calling the "PSM.estimate"
            %   command. The input is a column vector with 5 rows. The first
            %   row is temperature, second is precipitation, third is
            %   relative humidity, fourth is d18Os, fifth is d18Ov. 
            %   Uses the same state vector rows for each
            %   ensemble member and each ensemble in an evolving set.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with 5 rows, and one
            %   column per ensemble member. The rows should refer to the
            %   temperature, precipitation, relative humidity, d18Os, and 
            %   d18Ov variables (in that order).
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [5 x 1 x nEvolving] or of size 
            %   [5 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same rows for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use different rows for each ensemble member in each evolving ensemble.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows for the PSM object
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any currently specified rows from the object.
            % ----------
            %   Inputs:
            %       rows (linear indices, column vector [5]): The state vector rows that hold
            %           the climate variables required to run the cellulose sensor module.
            %           The first row is temperature, second is precipitation, third
            %           is relative humidity, fourth is d18Os, and fifth is d18Ov. Uses the same rows for
            %           all ensemble members and ensembles in an evolving set.
            %       memberRows (matrix, linear indices [5 x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
            %           be a matrix with 5 rows and one element per ensemble member. Uses
            %           the same rows for the ensemble members in different evolving ensembles.
            %       evolvingRows (3D array, linear indices [5 x 1|nMembers x nEvolving]):
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
                inputs = {rows, 5};
            end
            output = obj.parseRows(inputs{:});
        end
        function[d18O] = estimate(obj, X)
            %% PSM.prysm.cellulose.estimate  Estimates cellulose d18O values from T, P, RH, d18Os, and d18Ov
            % ----------
            %   d18O = <strong>obj.estimate</strong>(X)
            %   Runs the PRYSM cellulose sensor module on a set of
            %   temperatures, precipitations, relative humidities, d18Os,
            %   and d18Ov values extracted from a state vector ensemble.
            %   Estimates d18O values of cellulose.
            % ----------
            %   Inputs:
            %       X (numeric array [5 x nMembers x nEvolving]): The
            %           temperature, precipitation, relative humidity,
            %           d18Os, and d18Ov inputs used to run the PRYSM cellulose
            %           sensor module. The first row is temperature, second row is
            %           precipitation, third row is relative humidity,
            %           fourth row is d18Os, and fifth is d18Ov.
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
            d18Os = X(4,:,:);
            d18Ov = X(5,:,:);

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
                dSpy = py.numpy.array(d18Os(:,:,k));
                dVpy = py.numpy.array(d18Ov(:,:,k));

                % Run the forward model. Convert output back to Matlab
                d18Opy = py.psm.cellulose.sensor.cellulose_sensor(...
                    time, Tpy, Ppy, RHpy, dSpy, 0, dVpy, ...
                    obj.flag, obj.iso);
                d18O(:,:,k) = double(d18Opy);
            end
        end
    end

end
