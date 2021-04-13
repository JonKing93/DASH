classdef bayfoxPSM < PSM
    % Implements the BayFOX PSM, a Bayesian model for d18Oc of planktic
    % foraminifera by Jess Tierney.
    %
    % Find it on Github at: https://github.com/jesstierney/bayfoxm
    %
    % Or read the paper:
    % Malevich, S. B., Vetter, L., & Tierney, J. E. (2019). Global Core Top
    % Calibration of δ18O in Planktic Foraminifera to Sea Surface 
    % Temperature. Paleoceanography and Paleoclimatology, 34(8), 1292-1315.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2020
    
    properties
        species;
    end
    
    % Run directly
    methods (Static)
        function[Y, R] = run(t, d18Osw, species)
            %% Runs the BayFOX planktic foraminifera forward model
            %
            % [d18Oc, R] = bayfoxPSM.run(SST, d18Osw, species)
            % Applies the BayFOX PSM to a set of sea surface temperatues
            % and d18O (seawater) values to estimate d18O of calcite.
            %
            % ----- Inputs -----
            %
            % Please see the BayFOX documentation of the function
            % "bayfox_forward" for details on inputs.
            %
            % ----- Outputs -----
            %
            % d18Oc: Estimates of d18O of foram calcite. A vector.
            %
            % R: Error-variance uncertainties estimated from the posterior. A vector.
            
            assert(isnumeric(t) && isvector(t), 'T must be a numeric vector');
            assert(isnumeric(d18Osw) && isvector(d18Osw), 'd18Osw must be a numeric vector');
            
            % Run the PSM, collect Y and R from posterior
            d18Oc = bayfox_forward(t, d18Osw, species);
            Y = mean(d18Oc, 2);
            R = var(d18Oc, [], 2);
            
            % Shape to the SST vector
            if isrow(t)
                Y = Y';
                R = R';
            end
        end
    end
    
    methods
        % Constructor
        function[obj] = bayfoxPSM(rows, species, name)
            %% Creates a new bayfoxPSM object
            %
            % obj = bayfoxPSM(rows, species)
            % Creates a BayFOX PSM for a set of SST and d18O(sea-water)
            % values for a planktic foraminifera species.
            %
            % obj = bayfoxPSM(rows, species, name)
            % Optionally names the PSM.
            %
            % ----- Inputs -----
            %
            % rows: The state vector rows with the SST values and the
            %    d18Osw values needed to run the PSM. The first row should
            %    indicate SST values, the second row should indicate
            %    d18Osw.
            %
            % species: A string indicating the target species. Options are:
            %    'bulloides' = G. bulloides
            %    'incompta' = N. incompta
            %    'pachy' = N. pachyderma
            %    'ruber' = G. ruber
            %    'sacculifer' = T. sacculifer
            %    'all' = use the pooled annual (non-species specific) model
            %    'all_sea' = use the pooled seasonal (non-species specific) model
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
            % Runs a BAYFOX PSM given data from a state vector ensemble
            %
            % [Y, R] = obj.run(X)
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