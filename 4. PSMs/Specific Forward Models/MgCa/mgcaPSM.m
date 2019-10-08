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
    
    % PSM 
    methods
        % Get State Indices
        % 
        % This determines the indices of elements in a state vector that
        % should be used to run the forward model for a particular Mg/Ca
        % site.
        
        % Error Checking
        %
        function[] = errorCheckPSM( obj )
            if ~isvector( obj.H ) || length(obj.H)~=24
                error('H is not the right size.');
            end
            if ~ismember(obj.Species,obj.SpeciesNames)
                error('Species not recognized');
            end
        end
        % Now run the forward model
        function[mg,R] = runForwardModel( obj, M, ~, ~ )
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
            SSS=mean(M(gots_t+12,:),1);
            % Run the forward model. Output is 1500 possible estimates for
            % each ensemble member (nEns x 1000)
            mg = baymag_forward(obj.Age,SST,obj.Omega,SSS,obj.pH,obj.Clean,obj.Species,obj.SeaCorr,obj.PriorMean,obj.PriorStd,obj.bayes);
            
            % Estimate R from the variance of the model for each ensemble
            % member. (scalar)
            R = mean( var(mg,[],2), 1);
            
            % Take the mean of the 1500 possible values for each ensemble
            % member as the final estimate. (1 x nEns)
            mg = mean(mg,2);
            % transpose for Ye
            mg = mg';
        end
    end
end