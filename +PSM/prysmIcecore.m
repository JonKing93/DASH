classdef prysmIcecore < PSM.Interface
    %% Implements the icecore module of the PRYSM package
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
        altitudeDifference = 0;
    end
    
    methods (Static)
        function[d18O] = run(d18O, altitudeDifference)
            %% Runs the PRYSM icecore module
            %
            % d18O = prysmIcecore.run(d18O, altitudeDifference)
            % Runs the Prysm ice core model given d18O (precipitation) for
            % a site.
            %
            % ----- Inputs -----
            %
            % Please see the documentation of PRYSM module
            % "psm.icecore.sensor.icecore_sensor" for details on the
            % inputs.
            %
            % ----- Outputs -----
            %
            % d18O: Estimates of icecore d18O
            
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
            %% Creates a new prysmIcecore object
            %
            % obj = prysmIcecore(row, altitudeDifference)
            % Creates a PRYSM icecore PSM for d18O (precipitation) at a
            % proxy site.
            %
            % obj = prysmIcecore(..., name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % row: The state vector row with d18O (precipitation) needed to
            %    run the PSM.
            %
            % name: An optional name for the PSM (a string)
            %
            % Please see the documentation of PRYSM module
            % "psm.icecore.sensor.icecore_sensor" for details on the
            % remaining inputs.
            
            % Name, R estimation, rows
            if ~exist('name','var')
                name = "";
            end
            obj@PSM.Interface(name, false);
            obj = obj.useRows(row, 1);
            
            % Error check, set model inputs
            if exist('altitudeDifference','var') || isempty(altitudeDifference)
                dash.assert.scalarType(altitudeDifference, altitudeDifference, 'numeric', 'numeric');
                obj.altitudeDifference = altitudeDifference;
            end
        end
        
        function[d18O] = runPSM(obj, d18O)
            %% Runs a PRYSM ice core PSM given data from a state vector ensemble
            %
            % d18O = obj.run(X)
            % 
            % ----- Inputs -----
            %
            % X: The d18O (precipitation) data used to run the PSM. A
            %    numeric row vector.
            %
            % ----- Outputs -----
            %
            % d18O: Estimates of ice core d18O.
           
            d18O = obj.run(d18O, obj.altitudeDifference);
        end
    end
end