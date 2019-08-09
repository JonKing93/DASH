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
        % Get State Indices
        % 
        % This determines the indices of elements in a state vector that
        % should be used to run the forward model for a particular Mg/Ca
        % site.
        function[] = getStateIndices( obj, ensMeta, sstName, deloName, monthName, varargin ) 
            % Concatenate the variable names
            % varNames = [string(sstName), string(deloName)];
            % Get the time dimension
            [~,~,~,~,~,~,timeID] = getDimIDs;
            obj.H = getClosestLatLonIndex( obj.coord, ensMeta, sstName, timeID, monthName, varargin{:} );
            obj.H(13) = getClosestLatLonIndex( obj.coord, ensMeta, deloName);
        end
        % Error Checking
        %
        function[] = errorCheckPSM( obj )
            if ~isvector( obj.H ) || length(obj.H)~=13
                error('H is not the right size.');
            end
            if ~ismember(obj.Species,obj.SpeciesNames)
                error('Species not recognized');
            end
        end
        % Now run the forward model
        function[delo,R] = runForwardModel( obj, M, ~, ~ )
            %get ensemble means of SST and SSS for growth seasons
            SSTens = mean(M(1:12,:),2);
            %find the species
            species_ind = strcmp(obj.Species,obj.SpeciesNames);
            growth = obj.GrowthSeas(species_ind,:);
            %minimum months for seasonal average
            min_month = 3;
            %get months in range
            indt=SSTens >= growth(1) & SSTens <= growth(2);
            gots_t=find(indt);
            %get months outside of range
            nots_t=find(~indt);
        while length(gots_t) < min_month
            diffs(1,:)=abs(SSTens(nots_t)-growth(1));
            diffs(2,:)=abs(SSTens(nots_t)-growth(2));
            %find the closest value
            closest=min(diffs,[],[1 2]);
            %get its location
            [~,y]=find(diffs==closest);
            %update gots
            gots_t = [gots_t;nots_t(y)];
            %update nots
            nots_t(y)=[];
            clear diffs
        end
            %average months for seasonal T
            SST=mean(M(gots_t,:),1);
            %delosw should be the 13th entry in M
            d18Osw=M(13,:);
            % Run the forward model. Output is 1500 possible estimates for
            % each ensemble member (nEns x 1000)
            delo = bayfox_forward(SST,d18Osw,obj.Species,obj.bayes);
            
            % Estimate R from the variance of the model for each ensemble
            % member. (scalar)
            R = mean( var(delo,[],2), 1);
            
            % Take the mean of the 1500 possible values for each ensemble
            % member as the final estimate. (1 x nEns)
            delo = mean(delo,2);
            % transpose for Ye
            delo = delo';
        end
    end
end