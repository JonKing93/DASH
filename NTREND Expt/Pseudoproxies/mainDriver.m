% This is the driver for the pseudo proxy experiment

%%%%% User specified %%%%%
% Size of the static ensemble.
nEns = 11 * 10;

% Percent of variance set to R
Rfrac = 1;

% Set the months in the seasonal mean
season = [6 7 8];

% Set which years to use in the DA
yearLim = [850 950];
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate the time indices of the year limits
timeDex = yearLim - 850;
timeDex = timeDex(1)*12+1 : (timeDex(2)+1)*12;

%% Build the "true" pseudo proxies

% Do a linear regression against GHCN to get realistic values for the
% slope of a linear model.
[linReg, ghcnProxy, Tghcn] = build_GHCN_linear_model;

% Load the "true" data. So, run 2 of the LME. Use a set of years that 
% avoids possible climate biases (such as global warming post-1850). Also,
% restrict to the Northern Hemisphere.
[Tmeta, Ttrue] = getTruthRun( timeDex, season );

% Get the sampling indices of the NTREND sites
[~,~,~,sLon,sLat] = loadNTREND;
H = samplingMatrix( [sLat, sLon], [Tmeta.lat, Tmeta.lon], 'linear' );

% Create a linear model by adjusting the intercept of the linear regression
% to account for different mean values in the LME and GHCN data. This is
% will force the LME proxies from the linear model to have the same mean as
% the GHCN proxies from the regression.
linModel = tuneLinearModel( linReg, Ttrue(H,:), Tghcn.T );

% Create a proxy model object.
linPSM = linearPSM( linModel(:,1), linModel(:,2) );

% Calculate the "true" proxy values. These are the observations, D.
D = linPSM.runPSM( Ttrue(H,:) );

% Now, build a model ensemble for DA
[Mmeta, M] = build_NTREND_Ensemble( nEns, season, timeDex);

% Do a sanity check and ensure that Ttrue and M are using the same sites
if ~isequal(Mmeta.lat, Tmeta.lat) || ~isequal(Mmeta.lon, Tmeta.lon)
    error('Tmeta and Mmeta don''t record the same sites!');
end

% Get the Ye estimates
Ye = linPSM.runPSM( M(H,:) );

%% Run dash on the first time step
tDex = 1;
w = covLocalization([sLat, sLon], [Mmeta.lat, Mmeta.lon], 1000);
A1 = dash( M, D(:,tDex), zeros(size(D(:,tDex))), [], 1, linPSM, num2cell(H), []);

% Get the error of the initial and analysis ensembles
Mmean = mean(M,2);
Merr = Mmean - Ttrue(:,tDex);
Aerr = A1(:,1,1) - Ttrue(:,tDex);

skill = abs(Merr) - abs(Aerr);

figure
mapState(skill, Tmeta.iSize);
scicolor('flip');


