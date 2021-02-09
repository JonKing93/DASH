classdef baysparPSM < PSM
    % Implements the BAYSPAR TEX86 PSM.
    % Requires the Curve Fitting Toolbox
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties
        lat;
        lon;
        options;
    end
    
    methods
        % Constructor
        function[obj] = baysparPSM(row, lat, lon, options, name)
            %% Creates a new BAYSPAR PSM
            %
            % obj = baysparPSM(row, lat, lon)
            % Creates a BAYSPAR PSM for a site.
            %
            % obj = baysparPSM(row, lat, lon, options)
            % Optionally specify calibration parameters for the site.
            % (Please see the documentation for the TEX_forward function in
            % the BAYSPAR package)
            %
            % obj = baysparPSM(row, lat, lon, options, name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % row: The state vector row with the SST values required to run
            %    the PSM. A positive integer.
            %
            % lat: The latitude of the site. A numeric scalar.
            %
            % lon: The longitude of the site. A numeric scalar.
            %
            % options: A cell vector with up to three elements. The
            %    elements are the calibration parameter options as described
            %    in the documentation of the TEX_forward function in the
            %    BAYSPAR package. Use a empty array to retain the default
            %    options.
            %
            % name: An optional name for the PSM. A string.
            %
            % ----- Outputs -----
            %
            % obj: The new baysparPSM object
            
            % Set the name and estimatesR
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, true);
            
            % Check and set row
            assert(isscalar(row), 'row must be a scalar');
            obj = obj.useRows(row);
            
            % Error check the PSM inputs.
            if ~exist('options','var') || isempty(options)
                options = {};
            end
            [obj.lat, obj.lon, obj.options] = baysparPSM.checkInputs(lat, lon, options);
        end
        
        % Run the PSM
        function[Y, R] = runPSM(obj, SSTs)
            %% Runs a BAYSPAR PSM
            %
            % Y = obj.run(SSTs)
            %
            % ----- Inputs -----
            %
            % SSTs: The SSTs use to run the PSM. A numeric row vector
            %
            % ----- Outputs -----
            %
            % Y: Tex86 estimates
            %
            % R: Proxy uncertainties estimated from the posterior
            
            % Run the forward model, convert to row
            tex = TEX_forward(obj.lat, obj.lon, SSTs, obj.options{:});
            Y = mean(tex,2)';
            R = var(tex,[],2)';
            
        end
    end
    
    methods (Static)
        % Run directly
        function[Y, R] = run(lat, lon, ssts, options)
            
            % Error check the SSTs
            assert(isnumeric(ssts), 'ssts must be numeric');
            assert(isvector(ssts), 'ssts must be a vector');
            
            % Default options. Error check PSM parameters
            if ~exist('options','var') || isempty(options)
                options = {};
            end
            baysparPSM.checkInputs(lat, lon, options);
            
            % Run the PSM
            tex = TEX_forward(lat, lon, ssts, options{:});
            Y = mean(tex, 2);
            R = var(tex, [], 2);
            
            % Shape to the sst vector
            if isrow(ssts)
                Y = Y';
                R = R';
            end        
        end
            
        % Error check the PSM inputs
        function[lat, lon, options] = checkInputs(lat, lon, options)
            %% Error checks the PSM parameters
            %
            % [lat, lon, options] = baysparPSM.checkInputs(lat, lon, options)
            %
            % ----- Inputs -----
            %
            % lat: Site latitude. A numeric scalar.
            %
            % lon: Site longitude. A numeric scalar.
            %
            % options: Calibration options. A cell vector with up to 3
            %    elements.
            
            % Error check lat and lon
            dash.assertScalarType(lat, 'lat', 'numeric', 'numeric');
            dash.assertScalarType(lon, 'lon', 'numeric', 'numeric');
            dash.assertRealDefined(lat, 'lat');
            dash.assertRealDefined(lon, 'lon');
            
            % Error check calibration options
            dash.assertVectorTypeN(options, 'cell', [], 'options');
            if numel(options)>3
                error('options cannot contain more than 3 elements.');
            end
        end  
    end
    
end
            
            
            
            
            
            