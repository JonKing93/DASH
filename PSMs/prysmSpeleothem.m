classdef prysmSpeleothem < PSM
    
    properties
        timeStep;
        model = 'Adv-Disp';
        tau0 = 1;
        Pe = 1;
    end
    
    methods (Static)
        function[d18O] = run(d18O, T, timeStep, model, tau0, Pe)
            
            % Placeholder for time input
            time = 1:size(T,2);
            
            % Convert to numpy arrays
            d18O = py.numpy.array(d18O);
            T = py.numpy.array(T);
            time = py.numpy.array(time);
            
            % Run the PSM, convert back to Matlab numeric type
            d18O = py.psm.speleo.sensor.speleo_sensor(time, d18O, T, timeStep, model, tau0, Pe);
            d18O = numeric(d18O);
        end
    end
    
    methods
        function[obj] = prysmSpeleothem(rows, timeStep, model, tau0, Pe, name)
            
            % Name, R estimation, rows
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, false);
            obj.useRows(rows, 2);
            
            % Error check and set model inputs
            assert(isscalar(timeStep) && timeStep>0, 'timeStep must be a positive scalar');
            obj.timeStep = timeStep;
            if exist('model','var') && ~isempty(model)
                dash.assertStrFlag(model);
                assert(any(strcmp(model, ["Well-Mixed","Adv-Disp"])), 'model can either be "Well-Mixed" or "Adv-Disp"');
                obj.model = model;
            end
            if exist('tau0', 'var') && ~isempty(tau0)
                dash.assertScalarType(tau0, 'tau0', 'numeric', 'numeric');
                obj.tau0 = tau0;
            end
            if exist('Pe', 'var') && ~isempty(Pe)
                dash.assertScalarType(Pe, 'Pe', 'numeric', 'numeric');
                obj.Pe = Pe;
            end
        end
        
        function[d18O] = runPSM(obj, X)
            d18O = X(1,:);
            T = X(2,:);
            d18O = obj.run(d18O, T, obj.timeStep, obj.model, obj.tau0, obj.Pe);
        end
    end
end         