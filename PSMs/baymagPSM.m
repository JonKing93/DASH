classdef baymagPSM < PSM
    % Implements the BAYMAG Mg/Ca PSM.
    % Requires the Curve Fitting Toolbox
    
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
    
    methods
        % Constructor
        function[obj] = baymagPSM(row, age, omega, salinity, pH, clean, species, options, name)
            %% Creates a new BAYMAG PSM
            %
            % obj = baymagPSM(row, age, omega, salinity, pH, clean, species)
            % Creates a BAYMAG PSM for a site.
            %
            % obj = baymagPSM(..., options)
            % Specify optional parameters. (Please see the documentation
            % for the baymag_forward function in the BAYMAG package)
            %
            % obj = baymagPSM(..., options, name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % Please see the documentation of the baymag_forward function
            % in the BAYMAG package for more detailed descriptions of the
            % PSM parameters.
            %
            % row: The state vector row with the SST values required to run
            %    the PSM. A positive integer.
            %
            % age: The ages of the temperatures. A numeric scalar.
            %
            % omega: A scalar indicating bottom water saturation.
            %
            % salinity: A scalar of salinity (psu)
            %
            % pH: Scalar of pH (total scale)
            %
            % clean: A flag used to describe the cleaning technique.
            %
            % species: A string indicating the target species.
            %
            % options: A cell vector with up to 4 elements. Elements are
            % the optional parameters detailed in the BAYMAG documentation.
            %
            % name: An optional name for the PSM. A string.
            %
            % ----- Outputs -----
            %
            % obj: The new baysparPSM object
            
            % Set the name and estimatesR
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, true);
            
            % Check and set row
            assert(isscalar(row), 'row must be a scalar');
            obj = obj.useRows(row);
            
            % Error check the optional argument cell            
            if ~exist('options','var') || isempty(options)
                options = {};
            end
            dash.assertVectorTypeN(options, 'cell', [], 'options');
            assert(numel(options)<=4, 'options cannot have more than 4 elements.');
            
            % Set the inputs
            obj.age = age;
            obj.t = t;
            obj.omega = omega;
            obj.salinity = salinity;
            obj.pH = pH;
            obj.clean = clean;
            obj.species = species;
            obj.options = options;            
        end
        
        % Run the PSM
        function[Y, R] = runPSM(obj, T)
            %% Runs a BAYMAG PSM
            %
            % Y = obj.run(T)
            %
            % ----- Inputs -----
            %
            % T: The temperatures use to run the PSM. A numeric row vector
            %
            % ----- Outputs -----
            %
            % Y: Mg/Ca estimates
            %
            % R: Proxy uncertainties estimated from the posterior
            
            % Run the forward model, convert to row
            mgca = baymag_forward_ln(obj.age, T, obj.omega, obj.salinity, obj.pH, obj.clean, obj.species, obj.options{:});
            Y = mean(mgca, 2)';
            R = var(mgca, [], 2)';
        end
    end
    
    % Run directly
    methods (Static)
        function[Y, R] = run(age, t, omega, salinity, pH, clean, species, options)
            
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
            if isrow(ssts)
                Y = Y';
                R = R';
            end        
        end
    end    
end
 