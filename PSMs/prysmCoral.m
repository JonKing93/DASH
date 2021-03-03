classdef prysmCoral < PSM
    
    properties
        lat;
        lon;
        useSSS;
        species = "Default";
        b1 = 0.3007062;
        b2 = 0.2619054;
        b3 = 0.436509;
        b4 = 0.1552032;
        b5 = 0.15;
    end
    
    methods (Static)
        function[coral] = run(SST, SSS, d18O, lat, lon, species, b1, b2, b3, b4, b5)
            
            % d18O placeholder if using SSS
            if isempty(d18O)
                d18O = -1;
            end
            
            % Numpy arrays
            SST = py.numpy.array(SST);
            SSS = py.numpy.array(SSS);
            d18O = py.numpy.array(d18O);
            
            % Run PSM, convert output to Matlab numeric
            coral = py.psm.coral.sensor.pseudocoral(lat, lon, SST, SSS, d18O, species, b1, b2, b3, b4, b5);
            coral = numeric(coral);
        end
    end
    
    methods
        function[obj] = prysmCoral(rows, useSSS, lat, lon, species, bcoeffs, name)
            
            % Name, R estimation
            if ~exist('name', 'var')
                name = "";
            end
            obj@PSM(name, false);
            
            % Error check rows
            obj.useRows(rows);
            assert(numel(rows)==2, 'rows must have 2 elements');
            
            % Model inputs
            dash.assertScalarType(useSSS, 'useSSS', 'logical', 'logical');
            obj.useSSS = useSSS;
            dash.assertScalarType(lat,'lat','numeric','numeric');
            obj.lat = lat;
            dash.assertScalarType(lon,'lon','numeric','numeric');
            obj.lon = lon;
            dash.assertStrFlag(species, 'species');
            allowed = ["Default","Porites_sp","Porites_lob","Porites_lut","Porites_aus","Montast","Diploas"];
            dash.checkStrsInList(species, allowed, 'species', 'species name');
            obj.species = species;
            
            % b coefficients
            if exist('bcoeffs','var') && ~isempty(bcoeffs)
                dash.assertVectorTypeN(bcoeffs, 'numeric', [], 'bcoeffs');
                assert(numel(bcoeffs)<=5, 'bcoeffs cannot have more than 5 elements');
                for k = 1:numel(bcoeffs)
                    name = sprintf('b%.f', k);
                    obj.(name) = bcoeffs(k);
                end
            end
        end
        
        function[d18O] = runPSM(obj, X)
            SST = X(1,:);
            SSS = X(2,:);
            d18O = [];
            if ~obj.useSSS
                d18O = SSS;
            end
            d18O = obj.run(SST, SSS, d18O, obj.lat, obj.lon, obj.species, obj.b1, obj.b2, obj.b3, obj.b4, obj.b5);
        end
    end
    
end