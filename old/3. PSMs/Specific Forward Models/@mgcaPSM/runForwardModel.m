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
