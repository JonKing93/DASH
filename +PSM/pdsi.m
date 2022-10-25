classdef pdsi < PSM.Interface
    %% PSM.pdsi  Implements an estimator of Palmer Drought-Severity Index
    % ----------
    %   The pdsi forward model uses monthly temperature and monthly
    %   precipitation to estimate the Palmer Drought-Severity Index. This
    %   model uses the Thornthwaite estimation to calculate potential
    %   evapotranspiration. Includes options to return raw PDSI or modified
    %   PDSI. In either case, the model maintains significant memory of
    %   previous time steps.
    %
    %   The PDSI calculation is described in:
    %   Palmer, W.C. (1965) Meteorological drought, Vol. 30 (US Department of
    %   Commerce, Weather Bureau).
    %
    %   The Thornthwaite estimation is described in:
    %   Thornthwaite, C.W. (1948) An Approach toward a rational classification of
    %   climate. Geographical Review 38(1), 55-94.
    %
    %   Github Repository:  https://github.com/JonKing93/pdsi
    % ----------
    % pdsi Methods:
    %
    % *USER METHODS*
    %
    % Create:
    %   pdsi        - Creates a new pdsi PSM object
    %   label       - Apply a label to a pdsi object
    %
    % Estimate:
    %   rows        - Indicate the state vector rows that hold the monthly temperature and precipitation inputs
    %
    %
    % ==UTILITY METHODS==
    % Utility methods that help the class run. These are not intended for
    % users, and do not implement error checking on their inputs.
    %
    % Estimate:
    %   estimate    - Estimates pdsi using monthly temperature and precipitation
    %
    % Inherited:
    %   name        - Returns an identifying name for use in error messages
    %   parseRows   - Error checks and parses state vector rows
    %   disp        - Display the PSM in the console
    %
    % <a href="matlab:dash.doc('PSM.pdsi')">Documentation Page</a>

    % Description and repository
    properties (Constant)
        estimatesR = false;                                     % PDSI cannot estimate R uncertainties
        description = ...                                       % Description of the PSM
            "Palmer Drought-Severity Index using the Thornthwaite estimation";  
        repository = "JonKing93/pdsi";                          % Github repository for the PSM
        commit = "9a636117577f476a93f206897fb91dc94d4eddc2";    % The commit hash of the supported version
        commitComment = "Version 1.0.0. Most recent as of Oct. 25, 2022";       % Details about the commit
    end

    % Forward model parameters
    properties (SetAccess = private)
        season;         % The months over which to compute average PDSI
        years;          % The first and last year of input temperature/precipitation data
        lat;            % The latitude of the proxy site in decimal degrees north
        awcs;           % Available water capacity of the surface layer in mm
        awcu;           % Available water capacity of the underlying layer in mm
        cafecYears;     % The first and last year of the period used to compute the CAFEC normalization
        useModified;    % Whether to calculate standard or modified PDSI. True: Modified, False: Standard
    end

    methods
        function[obj] = pdsi(season, years, lat, awcs, awcu, cafecYears)
            %% PSM.pdsi.pdsi  Creates a new PDSI PSM object
            % ----------
            %   obj = <strong>PSM.pdsi</strong>(season, years, lat, awcs, awcu, cafecYears, season)
            %   Initializes a new PDSI PSM object. The first input indicates the season
            %   over which to estimate average PDSI. Currently, the DASH framework only
            %   implements PDSI seasons within a given calendar year. Seasons that
            %   cross multiple calendar years (such as DJF) are not yet supported. Note
            %   that the PDSI forward model itself *does* estimate values over multiple
            %   years, so you may want to run the model outside of DASH if estimating 
            %   PDSI in seasons that span multiple years.
            % 
            %   Please see the documentation of the "pdsi.m" function in the downloaded
            %   code for greater detail about the remaining inputs.
            %
            %   ***Important***
            %   The PDSI model maintains significant memory between individual years.
            %   Thus, we strongly recommend using a time-ordered ensemble when running
            %   this forward model.
            %
            %   obj = <strong>PSM.pdsi</strong>(..., useModified)
            %   obj = <strong>PSM.pdsi</strong>(..., true|'m'|'modified')
            %   obj = <strong>PSM.pdsi</strong>(..., false|'s'|'standard')
            %   Specify whether to estimate standard PDSI, or modified
            %   PDSI. Default is standard PDSI.
            % ----------
            %   Inputs:
            %       season (logical vector | vector, linear indices): Indicates 
            %           the season for which to estimate PDSI. A vector whose elements
            %           indicate months of the *calendar* year. The forward model will
            %           estimate the average PDSI value over these months.
            %
            %           If a logical vector, must have 12 elements. If linear indices,
            %           then the elements must be the (integer) numbers of months in
            %           the calendar year. For example, use 1:12 to estimate annual pdsi, 
            %           6:8 to estimate boreal-summer JJA pdsi, 6 to estimate June pdsi, 
            %           etc. 
            % 
            %           **Note**
            %           Using a season like [12 1 2] will not implement a DJF season
            %           spanning two calendar years. Instead, this will calculate the
            %           average PDSI over Jan, Feb, and Dec from the same calendar year
            %           (i.e. The December 10 months after the February)
            %       years (numeric vector [2]): The first and last year of the period
            %           in which monthly temperatures and precipitations will be input.
            %       lat (numeric scalar): The latitude of the site in decimal degrees north
            %       awcs (numeric scalar): The available water capacity of the surface
            %           layer in mm. A common default value is 25.4 mm.
            %       awcu (numeric scalar): The available water capacity of the
            %           underlying layer in mm. A common default value is 127 mm.
            %       cafecYears (numeric vector [2]): The first and last year of the
            %           calibration period used to compute CAFEC normalizations.
            %       useModified (scalar, string|logical): Indicates whether
            %           to estimate standard PDSI or modified PDSI.
            %           [true|"m"|"modified"]: The PSM will estimate modified PDSI
            %           [false|"s"|"standard"]: (Default) The PSM will estimate standard PDSI 
            %
            %   Outputs:
            %       obj (scalar PSM.pdsi object): The new PDSI PSM object
            %
            % <a href="matlab:dash.doc('PSM.pdsi.pdsi')">Documentation Page</a>

            % Header
            header = "DASH:PSM:pdsi";

            % Error check season
            dash.assert.vectorTypeN(season, 'numeric', [], 'season', header);
            season = dash.assert.indices(season, 12, 'season', ...
                'have one element per month', 'the number of months', header);
            if isempty(season)
                id = sprintf('%s:emptySeason', header);
                error(id, 'season must include at least one month');
            end
            dash.assert.uniqueSet(season, 'season', header);

            % Error check forward model inputs
            dash.assert.vectorTypeN(years, 'numeric', 2, 'years', header);
            dash.assert.scalarType(lat, 'numeric', 'lat', header);
            dash.assert.scalarType(awcs, 'numeric', 'awcs', header);
            dash.assert.scalarType(awcu, 'numeric', awcu', header);
            dash.assert.vectorTypeN(cafecYears, 'numeric', 2, 'cafecYears', header);

            % Parse standard vs modified
            if ~exist('useModified', 'var')
                useModified = false;
            end
            switches = {["s","standard"], ["m","modified"]};
            useModified = dash.parse.switches(useModified, switches, 1, ...
                                                'useModified', [], header);
            
            % Record parameters
            obj.season = season;
            obj.years = years;
            obj.lat = lat;
            obj.awcs = awcs;
            obj.awcu = awcu;
            obj.cafecYears = cafecYears;
            obj.useModified = useModified;
        end
        function[output] = rows(obj, rows)
            %% PSM.pdsi.rows  Indicate the stateVector rows used to run a PDSI PSM
            % ----------
            %   obj = <strong>obj.rows</strong>(rows)
            %   Indicate the state vector rows that should be used as the monthly
            %   temperature and monthly precipitation inputs to the PDSI PSM. The
            %   input is a column vector with 24 elements. The first 12 elements should
            %   be monthly temperatures from January to December (in that order). The
            %   last 12 elements should be monthly precipitation from January to
            %   December (also in that order).
            %
            %   obj = <strong>obj.rows</strong>(memberRows)
            %   Indicate which state vector row to use for each ensemble member. This 
            %   syntax allows you to use different state vector rows for different
            %   ensemble members. The input is a matrix with 24 rows and one element
            %   per ensemble member. The 24 rows should correspond to the climate
            %   variables described in the previous syntax.
            % 
            %   obj = <strong>obj.rows</strong>(evolvingRows)
            %   Indicate which state vector row to use for different  ensembles in an 
            %   evolving set. This syntax allows you to use different state vector rows
            %   for different ensembles in an evolving set. The input should be a 3D 
            %   array of either size [24 x 1 x nEvolving] or of size 
            %   [24 x nMembers x nEvolving]. If the second dimension has a size of 1,
            %   uses the same row for all the ensemble members in a particular evolving
            %   ensemble. If the second dimension has a size of nMembers, allows you to
            %   use a different row for each ensemble member in each evolving ensemble.
            %
            %   rows = <strong>obj.rows</strong>
            %   Returns the current rows for the PSM object
            %
            %   obj = <strong>obj.rows</strong>('delete')
            %   Deletes any currently specified rows from the PDSI PSM object.
            % ----------
            %   Inputs:
            %       row (column vector, linear indices [24 x 1]): The state vector rows that
            %           hold the monthly temperature and precipitation inputs required
            %           to run the PDSI PSM. The first 12 rows are monthly
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
            %       obj (scalar PSM.pdsi object): The PDSI PSM with updated rows
            %       rows (linear indices, [24 x 1|nMembers x 1|nEvolving]): The current
            %           rows for the PDSI PSM.
            %
            % <a href="matlab:dash.doc('PSM.pdsi.rows')">Documentation Page</a>

            % Parse the rows
            inputs = {};
            if exist('rows', 'var')
                inputs = {rows, 24};
            end
            output = obj.parseRows(inputs{:});
            
        end
        function[Ye] = estimate(obj, X)
            %% PSM.pdsi.estimate  Estimates PDSI from monthly temperature and precipitation
            % ----------
            %   Ye = <strong>obj.estimate</strong>(X)
            %   Runs the PDSI forward model on monthly temperatures and precipitation
            %   extracted from a state vector ensemble. Returns the average PDSI over
            %   the set of months selected by the user.
            % ----------
            %   Inputs:
            %       X (numeric array [24 x nMembers x nEvolving]): The monthly
            %           temperatures and precipitations used as inputs to the PDSI
            %           PSM. The first 12 rows should be temperatures from January to
            %           Decmember (in that order). The last 12 rows are temperatures
            %           from January to December (also in that order).
            %
            %   Outputs:
            %       Ye (numeric matrix [1 x nMembers x nEvolving]): Average PDSI values
            %           (or modified PDSI values) over the user-specified season.
            %
            % <a href="matlab:dash.doc('PSM.pdsi.estimate')">Documentation Page</a>
            
            % Split apart the climate inputs
            T = X( 1:12, :, :);
            P = X(13:24, :, :);
        
            % Reshape months and time into a single time dimension
            [nMembers, nEvolving] = size(T, 2:3);
            T = reshape(T, 12*nMembers, nEvolving);
            P = reshape(P, 12*nMembers, nEvolving);
        
            % Run the forward model. Either save standard or raw PDSI
            [X, Xm] = pdsi(T, P, obj.years, obj.lat, obj.awcs, obj.awcu, obj.cafecYears);
            if obj.useModified
                Ye = Xm;
            else
                Ye = X;
            end
        
            % Take the mean over the user-requested months
            Ye = reshape(Ye, 12, nMembers, nEvolving);
            Ye = Ye(obj.season, :, :);
            Ye = mean(Ye, 1);
        end
    end

end
