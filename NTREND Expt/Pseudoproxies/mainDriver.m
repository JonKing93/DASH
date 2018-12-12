% This is the driver for the pseudo proxy experiment

%%%%% User specified

% Size of the static ensemble.
nEns = 11 * 10;

% Percent of standard deviation set to R
Rfrac = 0.01;


%%%%%


% Do the initial linear regression
[linReg, gPseudo] = build_GHCN_linear_model;

% Tune the linear model to the CESM LME means and calculate the
% pseudo-proxies.
[linMod, trueProxy] = build_LME_Pseudos(linReg, gPseudo);

% Next step is actual data assimilation. Get all the pieces needed for DA
M = buildNTRENDEnsemble(nEns);
D = trueProxy{1};
R = Rfrac .* D;
Ye = applyPSM(linMod, M);



% Preallocate the static ensemble
Tmeta = loadLMESurfaceT;
nState = numel(Tmeta.lat);
nEns = nDraw * 11;
M = NaN( nState, nEns );

% Fill the static ensemble by drawing 10 random years from each model run,
% not including run 2.
rng('default');
nYear = size(Tmeta.date) ./ 12;
nRun = numel(Tmeta.run);

for r = 2:nRun
    
    % Load T from a run
    Trun = loadLMESurfaceT([],r);
    
    % Draw random time slices
    draw = ceil( randInterval(0, nTime, [nDraw,1]) );





