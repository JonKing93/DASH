% This is the driver for the pseudo proxy experiment

%%%%% User specified

% Size of the static ensemble.
nEns = 11 * 10;

% Percent of variance set to R
Rfrac = 1;

% Set the months in the seasonal mean
season = [6 7 8];

%%%%%

%% Build the "true" pseudo proxies

% Build or load the pseudo proxies

% % Do the initial linear regression
% [linReg, gPseudo] = build_GHCN_linear_model;
% 
% % Tune the linear model to the CESM LME means and calculate the
% % pseudo-proxies.
[linMod, trueProxy] = build_LME_Pseudos(linReg, gPseudo, season);

% Load
load('testPseudos.mat');

% Create the linear PSM
linPSM = linearPSM( linMod(:,2), linMod(:,1) );

%% Setup for DA

% Build (or load) the static ensemble
[M, Mmeta] = build_NTREND_Ensemble(nEns, season);
% load('testEnsemble_JJA.mat');

% Get D
D = trueProxy{1}';

% Get R
R = Rfrac .* var(D,[],2);
R = repmat(R, [1 size(D,2)]);

% Get the sampling indices
[~,year,~,sLon,sLat] = loadNTREND;
H = samplingMatrix( [sLat, sLon], [Mmeta.lat, Mmeta.lon], 'linear' );

% Get the Ye estimates
Ye = linPSM.runPSM( M(H,:) );

% Creat the sampling array for dashDA
Hcell = num2cell(H);

% Create the covariance localization
w = covLocalization( [sLat, sLon], [Mmeta.lat, Mmeta.lon], 25000);
% w = [];

%% Run DA

% Activate the parallel pool
gcp;

% Run the DA using the full PSM
Alin = dash( M, D(:,1), R(:,1), w, 1, linPSM, Hcell, []);

% Also run using the Tardif method
% Atar = dash( M, D(:,1), R(:,1), 'none', 1, Ye, [], []);


%% Compare to the true run

% Get the ensemble mean and variance
[Mmean, ~, Mvar] = decomposeEnsemble(M);

% Get the DA mean in the first time step
A1mean = Alin(:,1,1);

% Get the true value in the first time step
[Tmeta, T1] = loadLMESurfaceT( [], 1, season);
T1 = squeeze(T1);

NHdex = Tmeta.lat > 0;
T1 = T1(NHdex);
Tmeta.iSize = Tmeta.iSize ./ [1 2];

T1 = mean(T1,2);

% Get the error in M and A
Aerr = A1mean - T1;
Merr = Mmean - T1;
% Atarerr = Atarmean - T1;

% Get the skill improvement
skill = abs(Merr) - abs(Aerr);

% Plot the skill improvement.
figure
mapState( skill, Tmeta.iSize);
title('Skill Improvement');
scicolor;

% % subplot(1,2,1);
% % mapState(Merr, Tmeta.iSize);
% % title('Error in initial ensemble mean');
% % clim = get(gca,'clim');
% % scicolor;
% % 
% % subplot(1,2,2)
% % mapState(Aerr, Tmeta.iSize);
% % title('Error in output analysis mean');
% % set(gca,'clim',clim);
% % scicolor;
% % 
% % % subplot(1,3,3)
% % % mapState(Atarerr, Tmeta.iSize)
% % % title('Error in Tardif output');
% % % set(gca,'clim',clim);
% % % scicolor;