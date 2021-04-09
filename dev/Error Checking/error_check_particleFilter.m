%% Error check particle filter

Y  = rand(54, 1500);
whichPrior = [ones(500,1); 1+ones(500,1); 2+ones(500,1)];

Ye = rand(54, 200, 3);
R = abs(rand(54,1));
X = rand(115, 1500);


pf = particleFilter;
pf = pf.estimates(Ye, whichPrior);



pf = pf.uncertainties(R);
pf = pf.estimates(Ye, whichPrior);
pf = pf.observations(Y);