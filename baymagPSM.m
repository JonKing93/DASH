classdef baymagPSM < PSM
    % Implements the BAYMAG PSM, A Bayesian model for Mg/Ca of planktic
    % foraminiera by Jess Tierney.
    %
    % Prerequisites: Requires the Curve Fitting Toolbox
    %
    % Find it on Github at: https://github.com/jesstierney/bayfoxm  
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
        
    properties
        age;
        omega;
        salinity;
        pH;
        clean;
        species;
        options;
    end
    
     % Run directly
    methods (Static)
        function[Y, R] = run(age, t, omega, salinity, pH, clean, species, options)
            %% Runs the BayMAG planktic foraminifera forward model
            %
            % [mgca, R] = baymagPSM.run(age, SST, omega, salinity, pH, clean, species, options)
            % Applies the BayMAG PSM to a set of sea surface temperatures
            % to estimate Mg/Ca of planktic foraminifera.
            %
            % ----- Inputs -----
            %
            % Please see the BayMAG documentation of the function 
            % "baymag_forward_ln" for details on the inputs.
            %
            % options: A cell vector holding the "varargin" inputs for
            %    "baymax_forward_ln".
            %
            % ----- Outputs -----
            %
            % mgca: Mg/Ca estimates of planktic foraminifera. A vector.
            %
            % R: Error-variance uncertainties estimated from the
            %    posterior. A vector.
            
            % Error check the SSTs
            assert(isnumeric(t), 't must be numeric');
            assert(isvector(t), 't must be a vector');
            
            % Default for unspecified options.
            if ~exist('options','var') || isempty(options)
                options = {};
            end
            
            % Run the PSM
            mgca = baymag_forward_ln(age, t, omega, salinity, pH, clean, species, options{:});
            Y = mean(mgca, 2);
            R = var(mgca, [], 2);
            
            % Shape to the sst vector
            if isrow(t)
                Y = Y';
                R = R';
            end        
        end
    end
    
    methods
        % Constructor
        function[obj] = baymagPSM(row, age, omega, salinity, pH, clean, species, options, name)
            %% Creates a new baymagPSM object
            %
            % obj = baymagPSM(row, age, omega, salinity, pH, clean, species)
            % Creates a BAYMAG PSM for a set of SST values for a proxy site.
            %
            % obj = baymagPSM(..., options)
            % Specify optional parameters. (Please see the documentation
            % for the "baymag_forward_ln" function in the BAYMAG package)
            %
            % obj = baymagPSM(..., options, name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % row: The state vector row with the SST values needed to run
            %    the PSM.
            %
            % options: A cell vector with up to 4 elements. Elements are
            %    the optional parameters detailed in the BAYMAG
            %    documentation of the "baymag_forward_ln" function.
            %
            % name: An optional name for the PSM. A string.
            %
            % Please see the documentation of the "baymag_forward_ln"
            % function in the BAYMAG package for details on the remaining
            % inputs.
            %
            % ----- Outputs -----
            %
            % obj: The new baysparPSM object
            
            % Set the name, rows, and estimatesR
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, true);
            obj = obj.useRows(row, 1);
            
            % Error check the optional argument cell            
            if ~exist('options','var') || isempty(options)
                options = {};
            else
                dash.assertVectorTypeN(options, 'cell', [], 'options');
                assert(numel(options)<=4, 'options cannot have more than 4 elements.');
            end
            
            % Set the inputs
            obj.age = age;
            obj.omega = omega;
            obj.salinity = salinity;
            obj.pH = pH;
            obj.clean = clean;
            obj.species = species;
            obj.options = options;            
        end
        
        % Run the PSM
        function[Y, R] = runPSM(obj, T)
            %% Runs a BAYMAG PSM given data from a state vector ensemble
            %
            % Y = obj.run(T)
            %
            % ----- Inputs -----
            %
            % T: The sea surface temperatures use to run the PSM. A 
            %    numeric row vector.
            %
            % ----- Outputs -----
            %
            % Y: Mg/Ca estimates
            %
            % R: Proxy uncertainties estimated from the posterior
            
            % Run the forward model
            [Y, R] = baymagPSM.run(obj.age, T, obj.omega, obj.salinity, obj.pH, obj.clean, obj.species, obj.options{:});
        end
    end
end
 