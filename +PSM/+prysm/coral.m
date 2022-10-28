classdef coral < PSM.prysm.package
    %% PSM.prysm.coral  Implement the coral sensor module of the PRYSM package
    % ----------
    %   This PSM implements the coral sensor module from the PRYSM
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
    % coral Methods:
    %
    % *ALL USER METHODS*
    %
    % Create:
    %   coral       - Creates a new PRYSM coral object
    %   label       - Apply a label to a PRYSM coral object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold coral sensor module inputs
    %   
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates coral d18O values given SST, SSS, and optionally d18O extracted from a state vector ensemble
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.prysm.coral')">Documentation Page</a>

    % Description
    properties (Constant)
        description = ... Description of the PSM
            "Coral sensor module from the PRYSM Python package";
    end

    % Forward model parameters
    properties(SetAccess = private)
        lat;        % The latitude of the coral site
        lon;        % The longitude of the coral site

        d18O;       % Whether the forward model uses d18O as an input
        species;    % The species of coral
        b1;         % Red Sea d18O-SSS slope
        b2;         % Tropical Pacific d18O-SSS slope
        b3;         % South Pacific d18O-SSS slope
        b4;         % Indian Ocean d18O-SSS slope
        b5;         % Tropical Atlantic/Caribbean d18O-SSS slope
    end

    methods
        function[obj] = coral(lat, lon, varargin)
            %% PSM.prysm.coral.coral  Create a new PRYSM coral PSM object
            % ----------
            %   obj = <strong>PSM.prysm.coral</strong>(lat, lon)
            %   Creates a new PSM object that implements the PRYSM coral
            %   sensor module. Runs the model without d18O as an input
            %   using the default coral species and default d18O-SSS slope.
            %
            %   Please see the documentation of the "pseudocoral.py"
            %   function in the psm.coral.sensor module of PRYSM for
            %   additional details on the inputs.
            %
            %   obj = <strong>PSM.prysm.coral</strong>(..., 'd18O', d18O)
            %   Indicate whether the model should run using d18O as an
            %   input. Default is to not use it as an input.
            %
            %   obj = <strong>PSM.prysm.coral</strong>(..., 'species', species)
            %   Indicate the species of the coral. This sets the slope of
            %   the coral-SST regression. See details below.   
            %
            %   obj = <strong>PSM.prysm.coral</strong>(..., 'b1', b1)
            %   obj = <strong>PSM.prysm.coral</strong>(..., 'b2', b2)
            %   obj = <strong>PSM.prysm.coral</strong>(..., 'b3', b3)
            %   obj = <strong>PSM.prysm.coral</strong>(..., 'b4', b4)
            %   obj = <strong>PSM.prysm.coral</strong>(..., 'b5', b5)
            %   Set the d18O-SSS slope for different regions of the globe.
            % ----------
            %   Inputs:
            %       lat (numeric scalar): The latitude of the site in decimal degrees
            %       lon (numeric scalar): The longitude of the site in decimal degrees
            %       d18O (scalar logical): True if the model should use d18O as an
            %           input. Otherwise false (default).
            %       species (string scalar): The name of the coral species. This sets 
            %           the slope of the coral-SST regression.
            %           ["Default"]:      a = -0.22
            %           ["Porites_sp"]:   a = -.26178
            %           ["Porites_lob"]:  a = -.19646
            %           ["Porites_lut"]:  a = -.17391
            %           ["Porites_aus"]:  a = -.21
            %           ["Montast"]:      a = -.22124
            %           ["Diploas"]:      a = -.14992
            %       b1 (numeric scalar): Red sea d18O-SSS slope. Default is 0.31
            %       b2 (numeric scalar): Tropical Pacific d18O-SSS slope. Default is 0.27
            %       b3 (numeric scalar): South Pacific d18O-SSS slope. Default is 0.45
            %       b4 (numeric scalar): Indian Ocean d18O-SSS slope. Default is 0.16
            %       b5 (numeric scalar): Tropical Atlantic/Caribbean d18O-SSS slope. Default is 0.15
            %
            %   Outputs:
            %       obj (scalar PSM.prysm.coral object): The new PRYSM coral PSM object
            %
            % <a href="matlab:dash.doc('PSM.prysm.coral.coral')">Documentation Page</a>
        
            % Error check
            header = "DASH:PSM:prysm:coral";
            dash.assert.scalarType(lat, 'numeric', 'lat', header);
            dash.assert.scalarType(lon, 'numeric', 'lon', header);

            % Parse optional inputs
            [d18O, species, b1, b2, b3, b4, b5] = dash.parse.nameValue(varargin,...
                ["d18O", "species", "b1", "b2", "b3", "b4", "b5"],...
                {false,      "default", .31,  .27,   .45,  .16,  .15}, 2, header);
            dash.assert.scalarType(d18O, 'logical', 'use_d18O', header);
            species = dash.assert.strflag(species, 'species', header);
            dash.assert.scalarType(b1, 'numeric', 'b1', header);
            dash.assert.scalarType(b2, 'numeric', 'b2', header);
            dash.assert.scalarType(b3, 'numeric', 'b3', header);
            dash.assert.scalarType(b4, 'numeric', 'b4', header);
            dash.assert.scalarType(b5, 'numeric', 'b5', header);
    
            % Record parameters
            obj.lat = lat;
            obj.lon = lon;
            obj.d18O = d18O;
            obj.species = species;
            obj.b1 = b1;
            obj.b2 = b2;
            obj.b3 = b3;
            obj.b4 = b4;
            obj.b5 = b5;
        end
        function[output] = rows(obj, rows)
            %% PSM.prysm.coral.rows  Indicate the stateVector rows used to run the PRYSM coral sensor module
            % ----------
            %   obj = <strong>obj.rows</strong>(rows)
            %   Indicate the state vectors row that should be used as the 
            %   SSS, SST, and optionally d18O inputs for the coral sensor
            %   module when calling the "PSM.estimate" command. The input is 
            %   a column vector with either 2 or 3 rows. The first row is
            %   SST, and the second is SSS. If the model does not use d18O
            %   as input, then there should only be 2 rows. If the model
            %   uses d18O inputs, then a third row should locate d18O.
            %   Uses the same state vector rows for each
            %   ensemble member and each ensemble in an evolving set.
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector rows to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with 2 or 3 rows, and one
            %   column per ensemble member. The rows should refer to the
            %   SSS, SST, and optionally d18O variables (in that order).
            %
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [2|3 x 1 x nEvolving] or of size 
            %   [2|3 x nMembers x nEvolving]. If the second dimension has a size of 1,
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
            %       rows (linear indices, column vector [2|3]): The state vector rows that hold
            %           the climate variables required to run the coral sensor module.
            %           The first row is SST, second is SSS, and third
            %           is relative humidity. Uses the same rows for
            %           all ensemble members and ensembles in an evolving set.
            %       memberRows (matrix, linear indices [2|3 x nMembers]): Indicates
            %           which state vector rows to use for each ensemble member. Should
            %           be a matrix with 2 or 3 rows and one element per ensemble member. Uses
            %           the same rows for the ensemble members in different evolving ensembles.
            %       evolvingRows (3D array, linear indices [2|3 x 1|nMembers x nEvolving]):
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
            %       obj (scalar prysm.coral object): The coral PSM with updated rows
            %       rows (linear indices, [2|3 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the coral PSM
            %
            % <a href="matlab:dash.doc('PSM.prysm.coral.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                nRows = 2;
                if obj.d18O
                    nRows = 3;
                end
                inputs = {rows, nRows};
            end
            output = obj.parseRows(inputs{:});
        end
        function[d18O] = estimate(obj, X)
            %% PSM.prysm.coral.estimate  Estimates coral d18O values from SST, SSS, and optional d18O
            % ----------
            %   d18O = <strong>obj.estimate</strong>(X)
            %   Runs the PRYSM coral sensor module on a set of SST, SSS, and optional
            %   d18O values extracted from a state vector ensemble. Estimates d18O
            %   values of coral.
            % ----------
            %   Inputs:
            %       X (numeric array [2|3 x nMembers x nEvolving]): The SST, SSS, and
            %           optional d18O inputs used to run the PRYSM coral sensor module.
            %           First row is SST, second is SSS, optional third is d18O.
            %
            %   Outputs:
            %       d18O (numeric array [1 x nMembers x nEvolving]): Coral d18O
            %           estimates produced using the PRYSM coral sensor module.
            %
            % <a href="matlab:dash.doc('PSM.prysm.coral.estimate')">Documentation Page</a>
            
            % Split the variables
            SST = X(1,:,:);
            SSS = X(2,:,:);
            if obj.d18O
                d18Osw = X(3,:,:);
            end
            
            % Preallocate outputs for each evolving ensemble
            [nMembers, nEvolving] = size(SST, 2:3);
            d18O = NaN(1, nMembers, nEvolving);
            
            % For each evolving ensemble, convert variables to numpy array
            for k = 1:nEvolving
                SSTpy = py.numpy.array(SST(:,:,k));
                SSSpy = py.numpy.array(SSS(:,:,k));

                % Get d18O if appropriate
                if obj.d18O
                    input5 = py.numpy.array(d18Osw(:,:,k));
                else
                    input5 = -1;
                end
            
                % Run the forward model. Convert output to matlab numeric
                d18Opy = py.psm.coral.sensor.pseudocoral(obj.lat, obj.lon, ...
                    SSTpy, SSSpy, input5, obj.species, obj.b1, obj.b2, ...
                    obj.b3, obj.b4, obj.b5);
                d18O(:,:,k) = double(d18Opy);
            end
        end
    end
end
