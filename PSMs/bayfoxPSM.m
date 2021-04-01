classdef bayfoxPSM < PSM
    % Implements the BayFOX
    
    
    properties
        species;
    end
    
    % Run directly
    methods (Static)
        function[Y, R] = run(T, d18Osw, species)
            
            assert(isnumeric(T) && isvector(T), 'T must be a numeric vector');
            assert(isnumeric(d18Osw) && isvector(d18Osw), 'd18Osw must be a numeric vector');
            
            % Run the PSM, collect Y and R from posterior
            d18Oc = bayfox_forward(T, d18Osw, species);
            Y = mean(d18Oc, 2);
            R = var(d18Oc, [], 2);
            
            % Shape to the SST vector
            if isrow(T)
                Y = Y';
                R = R';
            end
        end
    end
    
    methods
        % Constructor
        function[obj] = bayfoxPSM(rows, species, name)
            %% Creates a new BAYSPLINE PSM
            %
            % obj = bayfoxPSM(rows, species)
            % Creates a BAYSPLINE PSM for a set of SST values.
            %
            % obj = bayfoxPSM(rows, species, name)
            % Optionally names the PSM.
            %
            % ----- Inputs -----
            %
            % rows: The state vector rows with the SST values and the
            %    d18Osw values needed to run the PSM. A vector of two
            %    integers. The first element should be the row for SST, and
            %    the second element is for d18Osw
            %
            % species: A string indicating the target species.
            %
            % name: An optional name for the PSM. A string
            %
            % ----- Outputs -----
            %
            % obj: The new baysplinePSM object
            
            % Set name, estimatesR, rows
            if ~exist('name','var')
                name = "";
            end
            obj@PSM(name, true);
            obj = obj.useRows(rows, 2);
            
            % Set the species parameter
            obj.species = species;
        end
        
        function[Y, R] = runPSM(obj, X)
            % Runs a BAYFOX PSM
            %
            % Y = obj.run(X)
            %
            % ----- Inputs -----
            %
            % X: The data used to run the PSM. A numeric matrix with two
            %    rows. First row is SST, second row is d18Osw
            %
            % ----- Outputs -----
            %
            % Y: Estimates of d18O of calcite
            % 
            % R: Proxy uncertainties estimated from the posterior
            
            % Split out the climate variables and run the model
            T = X(1,:);
            d18Osw = X(2,:);
            [Y, R] = bayfoxPSM.run(T, d18Osw, obj.species);
        end
    end
    
end