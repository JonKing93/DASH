classdef prysmCellulose < PSM
    %% Implements the cellulose module of the PRYSM package
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
        d18Os;
        d18Op;
        d18Ov;
        model = "Evans";
        useIsotopes = true;
    end
    
    methods (Static)
        function[d18O] = run(T, P, RH, d18Os, d18Op, d18Ov, model, useIsotopes)
            %% Runs the PRYSM Cellulose module
            %
            % d18O = prysmCellulose.run(T, P, RH, d18Os, d18Op, d18Ov, model, useIsotopes)
            % Runs the Prysm cellulose model given temperature,
            % precipitation, and relative humidity for a site.
            %
            % ----- Inputs -----
            %
            % Please see the documentation of PRYSM module
            % "psm.cellulose.sensor.cellulose_sensor" for details on the
            % inputs.
            %
            % ----- Outputs -----
            %
            % d18O: Estimates of d18O of cellulose.
            
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
            %% Creates a new prysmCellulose object
            %
            % obj = prysmCellulose(rows, d18Os, d18Op, d18Ov, model, useIsotopes)
            % Creates a PRYSM cellulose PSM for temperature, precipitation,
            % and relative humidity for a proxy site.
            %
            % obj = prysmCellulose(..., name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % rows: The state vector rows with the temperature,
            %    precipitation, and relative humidity data for the proxy site.
            %    First row should be temperature, second is precipitation,
            %    third should be relative humidity.
            %
            % name: An optional name for the PSM. A string.
            %
            % Please see the documentation of PRYSM module
            % "psm.cellulose.sensor.cellulose_sensor" for details on the
            % remaining inputs.
            
            % Name, R estimation, rows
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, false);            
            obj.useRows(rows, 3);
            
            % Error check model inputs
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
            %% Runs a PRYSM cellulose PSM given data from a state vector ensemble
            %
            % d18O = obj.run(X)
            % 
            % ----- Inputs -----
            %
            % X: The data used to run the PSM. A numeric matrix with three
            %    rows. First row is temperature, second row is precipitation,
            %    third row is relative humidity.
            %
            % ----- Outputs -----
            %
            % d18O: Estimates of d18O of cellulose.
            
            T = X(1,:);
            P = X(2,:);
            RH = X(3,:);
            d18O = obj.run(T, P, RH, obj.d18Os, obj.d18Op, obj.d18Ov, obj.model, obj.useIsotopes);
        end
    end
    
end