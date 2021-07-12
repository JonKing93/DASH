classdef prysmCoral < PSM.PSM
    %% Implements the coral module of the PRYSM package
    %
    % Prerequisites: Python 3.4, numpy, scipy, and rpy2. See the PRYSM
    % documentation for more details.
    %
    % Find PRYSM on Github at: https://github.com/sylvia-dee/PRYSM
    %
    % Or read the paper:
    % Dee, S. G., Russell, J. M., Morrill, C., Chen, Z., & Neary, A. 
    % (2018). PRYSM v2. 0: A proxy system model for lacustrine archives. 
    % Paleoceanography and Paleoclimatology, 33(11), 1250-1269.
        
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2020
    
    properties
        lat;
        lon;
        useSSS;
        species = "Default";
        bcoeffs = prysmCoral.b_default;
    end
    properties (Constant, Hidden)
        b_default = [0.3007062, 0.2619054, 0.436509, 0.1552032, .15];
    end
        
    methods (Static)
        function[coral] = run(lat, lon, SST, SSS, d18O, species, bcoeffs)
            %% Runs the PRYSM coral module
            %
            % coral = prysmCoral.run(SST, SSS, d18O, lat, lon, species, bcoeffs)
            % Runs the Prysm coral model given sea surface temperatures and
            % either sea surface salinities or d18O (sea-water) for a site.
            %
            % ----- Inputs -----
            %
            % Please see the documentation of PRYSM module
            % "psm.coral.sensor.pseudocoral" for details on the inputs.
            %
            % ----- Outputs -----
            %
            % coral: Coral estimates.
            
            % d18O placeholder if using SSS
            if isempty(d18O)
                d18O = -1;
            end
            
            % B coefficients
            b = PSM.prysmCoral.b_default;
            if exist('bcoeffs','var') && ~isempty(bcoeffs)
                dash.assert.vectorTypeN(bcoeffs, 'numeric', [], 'bcoeffs');
                assert(numel(bcoeffs)<=5, 'bcoeffs cannot have more than 5 elements');
                for k = 1:numel(bcoeffs)
                    if ~isnan(bcoeffs(k))
                        b(k) = bcoeffs(k);
                    end
                end
            end
            
            % Numpy arrays
            SST = py.numpy.array(SST);
            SSS = py.numpy.array(SSS);
            d18O = py.numpy.array(d18O);
            
            % Run PSM, convert output to Matlab numeric
            coral = py.psm.coral.sensor.pseudocoral(lat, lon, SST, SSS, d18O, species, b(1), b(2), b(3), b(4), b(5));
            coral = numeric(coral);
        end
    end
    
    methods
        function[obj] = prysmCoral(rows, useSSS, lat, lon, species, bcoeffs, name)
            %% Creates a new prysmCoral object
            %
            % obj = prysmCoral(rows, useSSS, lat, lon, species, bcoeffs, name)
            % Creates a PRYSM coral PSM for sea surface temperature and
            % either sea surface salinity or d18O (sea-water) for a site.
            %
            % obj = prysmCoral(..., name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % rows: The state vector rows with the temperature,
            %    precipitation, and relative humidity data for the proxy site.
            %    First row should be sea surface temperature, second should
            %    either be sea surface salinity or d18O (sea-water)
            %
            % useSSS: A scalar logical indicating whether the second set of
            %    state vector rows are for sea surface salinity (true) or
            %    d18O of sea-water (false)
            %
            % name: An optional name for the PSM. A string.
            %
            % Please see the documentation of PRYSM module
            % "psm.coral.sensor.pseudocoral" for details on the
            % remaining inputs.
            %
            % ----- Outputs -----
            %
            % obj: The new prysmCoral object
            
            % Name, R estimation, rows
            if ~exist('name', 'var')
                name = "";
            end
            obj@PSM.PSM(name, false);            
            obj = obj.useRows(rows, 2);
            
            % Model inputs
            dash.assert.scalarType(useSSS, 'useSSS', 'logical', 'logical');
            obj.useSSS = useSSS;
            dash.assert.scalarType(lat,'lat','numeric','numeric');
            obj.lat = lat;
            dash.assert.scalarType(lon,'lon','numeric','numeric');
            obj.lon = lon;
            dash.assert.strFlag(species, 'species');
            allowed = ["Default","Porites_sp","Porites_lob","Porites_lut","Porites_aus","Montast","Diploas"];
            dash.assert.strsInList(species, allowed, 'species', 'species name');
            obj.species = species;
            
            % b coefficients
            if exist('bcoeffs','var') && ~isempty(bcoeffs)
                dash.assert.vectorTypeN(bcoeffs, 'numeric', [], 'bcoeffs');
                assert(numel(bcoeffs)<=5, 'bcoeffs cannot have more than 5 elements');
                for k = 1:numel(bcoeffs)
                    if ~isnan(bcoeffs(k))
                        obj.bcoeffs(k) = bcoeffs(k);
                    end
                end
            end
        end
        
        function[d18O] = runPSM(obj, X)
            %% Runs a PRYSM coral PSM given data from a state vector ensemble
            %
            % d18O = obj.run(X)
            % 
            % ----- Inputs -----
            %
            % X: The data used to run the PSM. A numeric matrix with two
            %    rows. First row is sea-surface temperatures, second row is
            %    either sea-surface salinity or d18O (sea-water).
            %
            % ----- Outputs -----
            %
            % d18O: Estimates of d18O of cellulose.
            
            SST = X(1,:);
            SSS = X(2,:);
            d18O = [];
            if ~obj.useSSS
                d18O = SSS;
            end
            d18O = obj.run(obj.lat, obj.lon, SST, SSS, d18O, obj.species, obj.bcoeffs);
        end
    end
    
end