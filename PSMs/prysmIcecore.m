classdef prysmIcecore < PSM
    
    properties
        altitudeDifference = 0;
    end
    
    methods (Static)
        function[d18O] = run(d18O, altitudeDifference)
            
            % Placeholder time input
            time = 1:size(d18O,2);
            
            % Numpy arrays
            d18O = py.numpy.array(d18O);
            time = py.numpy.array(time);
            
            % Run the PSM, convert back to Matlab numeric type
            d18O = py.psm.icecore.sensor.icecore_sensor(time, d18O, altitudeDifference);
            d18O = numeric(d18O);
        end
    end
    
    methods
        function[obj] = prysmIcecore(row, altitudeDifference, name)
            
            % Name, R estimation, rows
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, false);
            obj.useRows(row, 1);
            
            % Error check, set model inputs
            if exist('altitudeDifference','var') || isempty(altitudeDifference)
                dash.assertScalarType(altitudeDifference, altitudeDifference, 'numeric', 'numeric');
                obj.altitudeDifference = altitudeDifference;
            end
        end
        
        function[d18O] = runPSM(obj, d18O)
            d18O = obj.run(d18O, obj.altitudeDifference);
        end
    end
end