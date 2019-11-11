classdef mgcaPSM < PSM
    
    properties
        %lat and lon coordinates of site
        coord;
        %pH needs to be passed to the PSM since it isn't modeled
        pH;
        %ditto with omega
        Omega;
        %you need to enter the cleaning method.
        Clean;
        %you need to give the PSM the species of foraminifera.
        Species;
        %age is needed for seawater correction in deep time. Otherwise it
        %is fine to pass a dummy value of zero.
        Age = 0; 
        %flag for seawater correction, default is none.
        SeaCorr = 0; 
        %Prior mean to limit forward model, default is 4;
        PriorMean = 4; 
        %Prior std to limit forward model, default is 4 (very wide).
        PriorStd = 4;
        %array of seasonal min and max values. note large dummy values for
        %annual models
        GrowthSeas = [3.6 29.2; 22.5 31.9; 6.7 21.1; -0.9 15.3; 20.2 30.6; -5 50; -5 50];
        %names of allowable species
        SpeciesNames = {'bulloides','ruber','incompta','pachy','sacculifer','all','all_sea'};
        %string array of Bayesian parameters. These are the default values.
        bayes = ["pooled_model_params.mat";"pooled_sea_model_params.mat";"species_model_params.mat"];
    end
    
    % Constructor
    methods
        % Constructor. This creates an instance of a PSM
        function obj = mgcaPSM( lat, lon, pH, Omega, Clean, Species, varargin )
            % Get optional inputs
            [age, sw, pmean, pstd, bayes] = parseInputs(varargin, {'Age','SeaCorr','PriorMean','PriorStd','Bayes'}, {[],[],[],[],[]}, {[],[],[],[],[]});
            
            % Set the coordinates
            obj.coord = [lat lon];
            % Set pH
            obj.pH = pH;
            % Set Omega
            obj.Omega = Omega;
            % Set Clean
            obj.Clean = Clean;
            % Set species
            obj.Species = Species;
            % Set optional arguments
            if ~isempty(age)
                obj.Age = age;
            end
            if ~isempty(sw)
                obj.SeaCorr = sw;
            end
            if ~isempty(pmean)
                obj.PriorMean = pmean;
            end
            if ~isempty(pstd)
                obj.PriorStd = pstd;
            end
            if ~isempty(bayes)
                obj.bayes = bayes;
            end
        end 
    end
    
    % PSM methods
    methods
        
        % Find the state vector elements needed to run the PSM
        getStateIndices( obj, ensMeta, sstName, sssName, monthName, varargin );
        
        % Internal error checking
        errorCheckPSM( obj );
        
        % Run the forward model and get Ye and R
        [mg,R] = runForwardModel( obj, M, ~, ~ )
        
    end
    
end