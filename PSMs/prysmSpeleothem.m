classdef prysmSpeleothem < PSM
    %% Implements the speleothem module of the PRYSM package
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
        timeStep = 1/12;
        model = 'Adv-Disp';
        tau0 = 1;
        Pe = 1;
    end
    
    methods (Static)
        function[d18O] = run(d18O, T, timeStep, model, tau0, Pe)
            %% Runs the PRYSM speleothem module
            %
            % d18O = prysmSpeleothem.run(d18O, T, timeStep, model, tau0, Pe)
            % Runs the Prysm cellulose model given d18O (dripwater) and
            % temperature at a speleothem site.
            %
            % ----- Inputs -----
            %
            % Please see the documentation of PRYSM module
            % "psm.speleo.sensor.speleo_sensor" for details on the
            % inputs.
            %
            % ----- Outputs -----
            %
            % d18O: Estimates of speleothem d18O (calcite).
            
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
            %% Creates a new prysmSpeleothem object
            %
            % obj = prysmSpeleothem(rows, timeStep, model, tau0, Pe)
            % Creates a PRYSM speleothem PSM given dripwater d18O and
            % temperature for a speleothem site.
            %
            % obj = prysmSpeleothem(..., name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % rows: The state vector rows with the d18O and temperature
            %    data. First row should be d18O, second row is temperature.
            %
            % name: An optional name for the PSM. A string.
            %
            % Please see the documentation of PRYSM module
            % "psm.speleo.sensor.speleo_sensor" for details on the
            % remaining inputs.
            %
            % ----- Outputs -----
            %
            % obj: The new prysmSpeleothem object
            
            % Name, R estimation, rows
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, false);
            obj = obj.useRows(rows, 2);
            
            % Error check and set model inputs
            assert(isscalar(timeStep) && timeStep>0, 'timeStep must be a positive scalar');
            obj.timeStep = timeStep;
            if exist('model','var') && ~isempty(model)
                dash.assert.strflag(model);
                assert(any(strcmp(model, ["Well-Mixed","Adv-Disp"])), 'model can either be "Well-Mixed" or "Adv-Disp"');
                obj.model = model;
            end
            if exist('tau0', 'var') && ~isempty(tau0)
                dash.assert.scalarType(tau0, 'tau0', 'numeric', 'numeric');
                obj.tau0 = tau0;
            end
            if exist('Pe', 'var') && ~isempty(Pe)
                dash.assert.scalarType(Pe, 'Pe', 'numeric', 'numeric');
                obj.Pe = Pe;
            end
            if exist('timeStep','var') && ~isempty(timeStep)
                assert(timeStep==1/12, 'timeStep must be 1/12 (monthly)');
            end
        end
        
        function[d18O] = runPSM(obj, X)
            %% Runs a PRYSM speleothem PSM given data from a state vector ensemble
            %
            % d18O = obj.run(X)
            % 
            % ----- Inputs -----
            %
            % X: The data used to run the PSM. A numeric matrix with three
            %    rows. First row is d18O (dripwater), second row is 
            %    temperature.
            %
            % ----- Outputs -----
            %
            % d18O: Estimates of speleothem d18O.
            
            d18O = X(1,:);
            T = X(2,:);
            d18O = obj.run(d18O, T, obj.timeStep, obj.model, obj.tau0, obj.Pe);
        end
    end
end         