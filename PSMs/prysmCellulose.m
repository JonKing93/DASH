classdef prysmCellulose < PSM
    
    properties
        d18Os;
        d18Op;
        d18Ov;
        model = "Evans";
        useIsotopes = true;
    end
    
    methods (Static)
        function[d18O] = run(T, P, RH, d18Os, d18Op, d18Ov, model, useIsotopes)
            
            % Placeholder for time input
            time = 1:size(T,2);
            
            % Convert numpy arrays
            time = py.numpy.array(time);
            T = py.numpy.array(T);
            P = py.numpy.array(P);
            RH = py.numpy.array(RH);
            
            % Get the model switch
            if strcmp(model, 'Roden')
                flag = 0;
            elseif strcmp(model, 'Evans')
                flag = 1;
            end
            
            % Run the model, convert to Matlab numeric
            d18O = py.psm.cellulose.sensor.cellulose_sensor(time, T, P, RH, d18Os, d18Op, d18Ov, flag, useIsotopes);
            d18O = numeric(d18O);
        end
    end
    
    methods
        function[obj] = prysmCellulose(rows, d18Os, d18Op, d18Ov, model, useIsotopes, name)
            
            % Name, R estimation
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, false);
            
            % Error check rows
            obj.useRows(rows);
            assert(numel(rows)==3, 'rows must have 3 elements');
            
            % Model inputs
            dash.assertScalarType(d18Os, 'd18Os', 'numeric', 'numeric');
            dash.assertScalarType(d18Op, 'd18Op', 'numeric', 'numeric');
            dash.assertScalarType(d18Ov, 'd18Ov', 'numeric', 'numeric');
            obj.d18Os = d18Os;
            obj.d18Op = d18Op;
            obj.d18Ov = d18Ov;
            
            dash.assertStrFlag(model);
            if exist('model','var') && ~isempty(model)
               dash.checkStrsInList(model, ["Roden","Evans"], 'model', 'model name');
               obj.model = model;
            end
            if exist('useIsotopes','var') && ~isempty(useIsotopes)
                dash.assertScalarType(useIsotopes, 'useIsotopes', 'logical', 'logical');
                obj.useIsotopes = useIsotopes;
            end
        end
    
        function[d18O] = runPSM(obj, X)
            T = X(1,:);
            P = X(2,:);
            RH = X(3,:);
            d18O = obj.run(T, P, RH, obj.d18Os, obj.d18Op, obj.d18Ov, obj.model, obj.useIsotopes);
        end
    end
    
end
            
