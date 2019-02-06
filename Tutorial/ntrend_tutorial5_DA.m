%% This tutorial shows how to run dash for NTREND using the VS-Lite forward
% model and CESM-LME temperature and precipitation output for the months
% May - September.
%
% This is the fifth and final module in the tutorial and focuses on
% actually running the DA.

%% Observations

% We're finally ready to start running dash. To run the DA, we will need to
% have observations and associated observation uncertainties.

% For the NTREND data, this is the tree ring widths. Let's load them
[RW, ~,~, treeLon, treeLat] = loadNTREND;

% We'll transpose them so that they are obs x time, rather than vice versa
RW = RW';

% Also delete the bad sites
del = [52;2;20;9];
RW(del,:) = [];
treeLon(del) = [];
treeLat(del) = [];

% We also need some observation uncertainty. Here, we'll just use 10% of
% the standard deviation at each site.
r = 0.1 * nanstd(RW, [], 2);

% We'll need uncertainty observations for each DA time step, so we'll
% repmat this over our time steps
nTime = size(RW,2);
r = repmat(r, [1, nTime]);

%% Inflation factor.

% We might also want to provide an inflation factor. This is a scalar that
% amplifies the variance in the model ensemble. It may be necessary to
% prevent filter divergence in the DA.
%
% There are no few strict criteria for setting an inflation factor, and
% sensitivity testing is strongly encouraged. Here, we'll set an inflation
% factor of 2, which will double model variance.
inflate = 2;

%% Covariance localization

% We may wish to impose some spatial localization on the observations. With
% this localization an observation cannot affect the analysis beyond some
% cutoff radius.
%
% The covLocalization function calculates the weights for the localization.
% It needs to be given the lat-lon coordinates of observations, and also of
% the model ensemble. It also must be given some cutoff radius R.
% Observations cannot affect grid nodes outside of this radius. The
% localization can also be optionally given a scale length, which affects
% how quickly the localization tapers aways from the observation. If you
% are interested in adjusting the scale length, please see the advanced
% documentation.
%
% So, for our NTREND experiment, we have the site Lat and Lon coordinates
% (treeLon and treeLat). We also need the coordinates of the state vector
% elements. This information is stored in the ensemble metadata (ensMeta),
% which we created in module 3. So we will need to provide ensMeta.lat and
% ensMeta.lon.
%
% Currently, covLocalization converts the metadata value of spatial means
% to NaN. So spatial means will be unaffected by any localization. Future
% releases of dash will add additional flexibility to this utility.

% So, let's do a cutoff radius of 10000 km.
cutoff = 10000;
w = covLocalization( [treeLat, treeLon], [ensMeta.lat, ensMeta.lon], cutoff );

% So, this function says: here are the coordinates of my observation sites.
% Here are the coordinates of the state vector elements. I want to prevent
% observations from affecting the analysis outside of this cutoff radius.
% The function then returns w, the covariance localization weights.
%
% If we look at the size of w
disp(size(w));

% we can see that it is 69121 elements long x 50 observation sites. So each
% column gives the localization weights for each state vector element for a
% particular observation site. Note that the final element of the
% localization 
disp( w(end,:) );

% is always 1. This is because the last element in the state vector is the
% "T Mean" variable, which is a spatial mean. Since dash disables
% covariance localization for spatial means, the localization weight is 1
% (So the spatial mean innovation will be unaffected in the DA).

% One important note: The cutoff radius units are in kilometers.

%% Data Analysis

% Alright, we're ready to run the DA!

% At this point we have a model ensemble M (the prior), Observations (RW),
% observation uncertainties (r), a covariance localization (w), an
% inflation factor (inflate), and some PSMs (F).

% We want to run the DA and return an update analysis (A). This is the
% updated ensemble mean and variance for each state vector element in each
% DA time step.
%
% There is one last option, we should be aware of. Dash supports two data
% assimilation methods. The first, a 'full' DA, uses the full PSM at each
% update in each time step. This may be more computationally expensive but
% (if the PSMs are skillful), should give more accurate results.
%
% In the second DA method, dash will use the PSMs to pre-calculate a set of
% model estimates. Dash will then append these model estimates to the end
% of the state vector and update them in a strictly linear manner via the
% Kalman Gain. This is known as the 'append' DA method. When we call dash,
% we will need to specify which method we want.

% Okay, let's run dash. For the sake of a fast tutorial, we'll just do a
% single timestep
tstep = 800;
A = dash( M, RW(:,tstep), r(:,tstep), w, inflate, 'full', F);

% Aaaaaand we're done!

% You may have noticed output in the terminal indicating that some of the
% PSMs failed to run. This is because the LME models are biased relative to
% the CRU data that I used to generate T and M thresholds. vslitePSMs
% actually have a bias correct option, but I did not use them in this
% tutorial in order to illustrate this point:
%
% It is alright for a PSM to fail or throw an error during a dash analysis.
% Obviously, it would be better if the PSM did not fail, but if a failure
% does occur you will not lose the analysis. Instead, dash will simply skip
% the observation with the failed PSM and not use it in the serial
% observations of the current time step. 
%
% In this tutorial, we only ran a single timestep, but in real analyses we
% will probably want to run over 100s or 1000s of time steps. It would be
% terrible if we ran 999 out of 1000 time steps (which could take a long
% time to run), only to have a PSM crash and lose the entire analysis.
%
% Additionally, this allows the user to use PSMs "out of the box" without
% needing to debug them or even understand the internal code of the PSM.
% (Although, to permanently fix a crashing PSM, you may need to investigate
% its code.)

%% Regridding.

% We'll probably want to regrid our data to look at it spatially. The
% regridAnalysis function provides this utility for individual variables at
% specific time steps.
%
% To regrid, we need to provide either the update mean or the update
% variance at a particular time step. We had 1262 time points in NTREND
% with observations. Let's do time step 800, since there were few NaN data
% points.

% So we're going to extract the mean of the update analysis at the first
% time step (recall that we only ran a single time step.
rA = A(:,1,1);

% That is, we select all state vector elements in time step 1 of the
% statistic 1 (the mean) in the output. Just to note, the third dimension
% of the output specifies different ensemble statistics. A(:,:,1) shows
% ensemble mean values, A(:,:,2) shows ensemble variance.

% Now we want to regrid. We will need to specify which variable we want to
% regrid, and provide the ensemble metadata (which tells where the variable
% is located), as well as the state vector design (which knows the original
% dimensions of this grid).

% So, to regrid
[rA, dimID] = regridAnalysis( rA, 'T', ensMeta, d );

% If we look at the size of rA
size(rA)

% we see that rA is a 1 x 1 x 48 x 144 x 5 grid. By looking at the dimID
% output, we see that this corresponds to dimensions lev x run x lat x lon
% x time.

% We are now free to process or map this grid however we like.

% It's important to note that the dimensional ordering may be different for
% different analyses. So you should always check dimID to see the ordering
% of your data after regridding.

%% Notes

% If you don't want to apply an inflation factor or a covariance
% localization, just use an empty array as input.

% There is a reason you can only regrid one time step at a time. This is
% because there exist both a time dimenion for the gridded data AND a time
% dimension for the DA. These are not necessarily the same. For example, in
% this NTREND experiment, the time dimension for gridded data is May - September,
% whereas the time dimension of the DA is for observation years 750 - 2011.
%
% This could result in an ambiguity, so the user is required to track DA time.
% Future releases may attempt to resolve this...
