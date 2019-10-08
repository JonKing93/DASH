classdef deloPSM < PSM
    
    properties
        %lat and lon coordinates of site
        coord;
        %you need to give the PSM the species of foraminifera.
        Species;
        %array of seasonal min and max values. note large dummy values for
        %annual models
        GrowthSeas = [3.6 29.2; 22.5 31.9; 6.7 21.1; -0.9 15.3; 20.2 30.6; -5 50; -5 50];
        %names of allowable species
        SpeciesNames = {'bulloides','ruber','incompta','pachy','sacculifer','all','all_sea'};
        %string array of Bayesian parameters. These are the default values.
        bayes = ["poolann_params.mat";"poolsea_params.mat";"hiersea_params.mat"];
    end
    
    % Constructor
    methods
        % Constructor. This creates an instance of a PSM
        function obj = deloPSM( lat, lon, Species, varargin )
            % Get optional inputs
            [bayes] = parseInputs(varargin, {'Bayes'}, {[]}, {[]});
            
            % Set the coordinates
            obj.coord = [lat lon];
            % Set species
            obj.Species = Species;
            % Set optional arguments
            if ~isempty(bayes)
                obj.bayes = bayes;
            end
        end
    end
    
    % PSM methods
    methods
        
        % Get the state vector elements needed to run the PSM
        getStateIndices( obj, ensMeta, sstName, deloName, monthMeta, varargin );
        
        % Internal error checking
        errorCheckPSM( obj );
        
        % Generate Ye and R from ensemble
        [delo,R] = runForwardModel( obj, M, ~, ~ )
        
    end
        
end