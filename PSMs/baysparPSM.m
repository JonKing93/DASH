classdef baysparPSM < PSM
    % Implements the BAYSPAR PSM, a Bayesian model for TEX86 by Jess Tierney
    %
    % Prerequisites: Requires the Curve Fitting Toolbox
    %
    % Find it on Github at: https://github.com/jesstierney/BAYSPAR
    %
    % Or read the paper:
    % Tierney, J.E. & Tingley, M.P. (2014) A Bayesian, spatially-varying 
    % calibration model for the TEX86 proxy. Geochimica et Cosmochimica 
    % Acta, 127, 83-106. https://doi.org/10.1016/j.gca.2013.11.026.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties
        lat;
        lon;
        options;
    end
    
    methods (Static)
        % Run directly
        function[Y, R] = run(lat, lon, ssts, options)
            %% Runs the BaySPAR TEX86 forward model.
            %
            % [tex86, R] = baysparPSM.run(lat, lon, ssts, options)
            % Applies the BaySPAR PSM to a set of sea surface temperatures
            % for a proxy site.
            %
            % ----- Inputs -----
            %
            % Please see the BayFOX documentation on the function
            % "TEX_forward" for details on the inputs.
            %
            % options: A cell vector holding the "varargin" inputs for
            %    "TEX_forward".
            %
            % ----- Outputs -----
            %
            % tex86: TEX86 estimates. A vector
            %
            % R: Error-variance uncertainties estimated from the posterior.
            %    A vector.
            
            % Error check the SSTs
            assert(isnumeric(ssts), 'ssts must be numeric');
            assert(isvector(ssts), 'ssts must be a vector');
            
            % Default options. Error check PSM parameters
            if ~exist('options','var') || isempty(options)
                options = {};
            end
            
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
            
            % Set the name, rows, and estimatesR
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, true);
            obj = obj.useRows(row,1);
            
            % Error check the PSM inputs.
            if ~exist('options','var') || isempty(options)
                options = {};
            else
                dash.assert.vectorTypeN(options, 'cell', [], 'options');
                assert(numel(options)<=3, 'options cannot have more than 3 elements');
            end
            
            % Save the inputs
            obj.lat = lat;
            obj.lon = lon;
            obj.options = options;
        end
        
        % Run the PSM
        function[Y, R] = runPSM(obj, SSTs)
            %% Runs a BAYSPAR PSM
            %
            % Y = obj.run(SSTs)
            %
            % ----- Inputs -----
            %
            % SSTs: The SSTs use to run the PSM. A numeric row vector.
            %
            % ----- Outputs -----
            %
            % Y: Tex86 estimates
            %
            % R: Proxy uncertainties estimated from the posterior
            
            % Run the forward model, convert to row
            [Y, R] = baysparPSM.run(obj.lat, obj.lon, SSTs, obj.options);
            
        end
    end
end