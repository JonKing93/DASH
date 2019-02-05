%% This tutorial shows how to run dash for NTREND using the VS-Lite forward
% model and CESM-LME temperature and precipitation output for the months
% May - September.
%
% This is the fourth module in the tutorial and focuses on PSMs.

%% Introduction to PSMs

% Ah PSMs, where everything gets complicated...
%
% So, there are an infinite number of possible PSMs we can use for data
% assimilation, and they will all work differently. Thus, I cannot give a
% tutorial on how to use every PSM.
%
% Instead, this tutorial will discuss the similarities among all PSMs and
% then show and example workflow using a PSM for VS-Lite.
%
% (This tutorial will NOT go into any detail on how to build a PSM. If you
% are interested in creating new PSMs, please see the "PSM Development"
% documentation.)

% So, since there are infinitely many possible PSMs, it would be futile to
% try to code them directly into dash. Thus, within Dash, PSMs are
% implemented as PSM objects. That is, each PSM is written as a unique
% class.
%
% If you are unfamiliar with object-oriented programming, just know that
% each PSM is written as a special piece of software that is capable of
% running itself.
%
% Each of these PSMs is required to use a specific interface to interact
% with dash. The key part of this interface is that EVERY PSM is required
% to include the function "runPSM". This allows the data assimilation to
% run ANY PSM with a single line of code (PSM.runPSM). Since the PSM
% everything needed to run itself, it can run itself and perform any
% analyses without any additional input from dash.
%
% As a user, you do not really need to know this. Nor do you need to know
% anything about the "runPSM" function or the PSM interface. This is just
% to explain why dash implements PSMs as class objects.

% If this is the case, then what should you be aware of?
%
% In general, it is useful to know about two PSM functions
% 1. Constructors, and
% 2. getStateIndices

%% Constructors

% So what is a constructor?
%
% A constructor is the function that you use to initialize a PSM. 

% Before going any further, we should clarify an important point:
% You need to make a unique PSM for each observation used in data
% assimilation. The PSM classes do not define a single, fixed way to run a
% PSM. Instead, they tell how to make a matlab object/variable that knows
% how to run a PSM for a specific observation.
%
% If you are not familiar with object-oriented programming, let me
% emphasize this again. When you create a PSM object it is NOT analogous to
% editing the actual code in a model. Rather, it is analogous to running a
% model with different inputs.
%
% So if I run DA on 50 NTREND sites, I will need to create 50 VS-Lite PSM
% objects. Each of these 50 PSMs knows how to run the VS-Lite code, but
% will use input arguments to VS-Lite that are specific to a particular
% observation.


% Alright, back to constructors. So the constructor is the function you use
% to make the individual PSM objects. 
%
% The constructor is always the name of the PSM. So, in this tutorial, I will
% be working with a PSM for VS-Lite. The name of this PSM is vslitePSM. So
% to create a vslitePSM, I will need to use the function "vslitePSM".

% There is very little practical difference between a constructor and a
% normal function in MATLAB. The constructor has some input arguments,
% which are unique to each PSM. To learn about the input arguments, you can
% see the help section of the constructor. So for vslitePSM, the line
help vslitePSM

% gives information on how to run the constructor. We can see that I need
% to provide lat and lon coordinates for my site, temperature and moisture
% thresholds, and there are some other optional arguments such as seasonal
% response or parameters for the leaky bucket model.
%
% These are not the inputs I will need for other PSMs because all PSMs are
% different, just like functions. So look at the documentation / help for
% your PSMs to learn how to run them. (And if there is no documentation,
% please throw something at whoever programmed it.)

% So, let's use the PSM constructors for NTREND.

% I'm going to start by loading information about the NTREND sites
[~,~,season, lon, lat] = loadNTREND;

% I'm also going to load some temperature and moisture thresholds that I
% calculated using the estimate_vslite_params.m script trained on CRU data.
TP = load('TPthreshold.mat');
T1 = TP.T1;
T2 = TP.T2;
M1 = TP.M1;
M2 = TP.M2;

% Finally, I'm going to load monthly mean temperature climatologies I
% calculated for each site using the mean of run 2 of TREFHT in the grid
% nodes closest to the NTREND sites. This will be used as the temperature
% climatology for the leaky bucket model / Thornthwaite equations.
Tclim = load('Tclim.mat');
Tclim = Tclim.Tclim;

% Alright, now I'm going to remove a few sites from this dataset. The
% thresholds for site 52 didn't converge, and sites 2 and 20 are sensitive
% to months outside of May - September, and VS-Lite has negative skill at
% reconstructing tree rings at site 9 using CRU data.
del = [52;2;20;9];
season(del) = [];
lon(del) = [];
lat(del) = [];
T1(del) = [];
T2(del) = [];
M1(del) = [];
M2(del) = [];
Tclim(:,del) = [];

% Alright, now I'm going to preallocate a cell array to hold the PSMs for
% the remaining 51 sites. It is important to use a cell array and not a
% numeric array because dash assumes that all PSMs are in a cell array.
% This is because you cannot concatenate different PSM types in a [] array.
F = cell(51,1);

% Now, I'm going to use the constructor function for each NTREND site. Each
% time I call it, I will give it the coordinates, T and M thresholds, the
% seasonality of a specific site, and a temperature climatology with which
% to run the leaky-bucket model.
%
% I'm also going to give each PSM a temperature conversion value. This is
% because the data stored in Tref-LME.grid is in units of Kelvin, but the
% actual VS-Lite model needs temperature inputs in Celsius. By providing
% this temperature conversion, I will allow the PSM to convert the data in
% dash into a form that is usable for VS-Lite.
% 
% Similarly, I'm also going to give each PSM a precipitation conversion.
% The data in the grid file is in m/s, but VS-Lite uses mm/month.
for s = 1:numel(F)
    F{s} = vslitePSM( [lat(s), lon(s)], T1(s), T2(s), M1(s), M2(s), Tclim(:,s), ...
        'intwindow', season{s}, 'convertT', -273.15, 'convertP', 2.592E9 );
end

% If you are familiar with VS-Lite, this code should look mostly familiar. It is
% essentially the first several inputs to the VS-Lite code, but without
% temperature or precipitation data.
%
% Essentially, what we have done here is given the PSM the inputs it needs
% so that, when it is given temperature and precipitation data in the DA,
% it is able to run VS-Lite.

% If you're curious about the PSMs, we can look at F
disp(F);

% and see that it is an array of PSM objects. Looking at the first of these
disp( F{1} );

% we can see that it is for a site located at [65, -161], with some
% particular T and M thresholds and a seasonality (intwindow) of July and
% August. When dash runs a PSM for this observation, the PSM will use these
% inputs.

% If we look at the next PSM
disp( F{2} );

% we can see it is for a site at [62.5, -141.5] with some different
% thresholds, and a different seasonality, (June, July and August). When
% dash runs a PSM for this observation, the PSM will run VS-Lite using
% these different inputs.

% Some terminology: The individual PSM objects (like the first and
% second PSMs we just looked at), are known as an "instance" of a PSM.
%
% So, for example, vslitePSM is a PSM because it is the code that describes
% how to run VS-Lite for any observation.
%
% But F{1} is an instance of a vslitePSM because it actually holds the
% values needed to run a vslitePSM for a specific observation.

%% getStateIndices

% Aside from the constructor, there is one other important function that
% ALL PSMs will have.
%
% This method is called "getStateIndices" and is responsible for deciding
% which elements in a state vector are needed to run an instance of the PSM.
%
% So, for VS-Lite, this would be the temperature and precipitation elements
% in a particular time step that are closest to an NTREND site.

% Again, since all PSMs are different, this function will have different
% inputs for every PSM. To learn about the different inputs needed for
% a specific PSMs, you will need to look at the PSM's documentation.

% However, "getStateIndices" is actually a a bit of software known as a
% "method". It is very similar to a function, but is slightly different.
%
% Aside from a few practical points, you don't need to know about functions
% and methods. The first practical point is that getStateIndices (a
% method), is associated with a each PSM (e.g. vslitePSM). So to look at
% the help section of getStateIndices for a specific PSM, you will need to
% look at the help section of the PSM. So if I do
help vslitePSM

% I can scroll down and see the inputs I need to run getStateIndices for
% the vslitePSM. The code
% >> help getStateIndices
% would not be useful.

% This is because getStateIndices is different for every PSM, so there are
% infinite possible help sections, and putting a help section in the
% function would be meaningless.

% The second practical difference between a method and a function is that a
% method must be run by an instance of a class.
%
% So to run getStateIndices for my vslitePSMs, I will need to do
% >> F{1}.getStateIndices
% or
% >> F{2}.getStateIndces
% etc.
%
% This is because each instance of the vslitePSM will need different state
% elements to run. Recall that F{1} has information for the NTREND site at
% [65, -161], while F{2} has information for the site at [62.5, -141.5].
% 
% To run VS-Lite for site 1, we will need state vector elements for T and P
% that are closest to [65, -161], while for site 2, we will need state vector
% elements for T and P that are closest to [62.5, -141.5]. Since we need
% different state vector elements for each instance of the PSM, we need to
% run "getStateIndices" for each instance of the PSM.
%
% Practically, the way to do this is with dot indexing. Do an instance of a
% PSM followed by .getStateIndices( Input Arguments ) to run the method.

% So, let's do this for the VS-Lite PSMs. From the help section, we can see
% that, in order to find the correct state elements, getStateIndices for
% vslitePSMs needs to know the ensemble metadata, name of the temperature
% variable, name of the precipitation variable, and the metadata values of
% the months for which the site is sensitive to climate.

% We have ensemble metadata (from the previous module), and know the names
% of the T and P variables
Tname = 'T';
Pname = 'P';

% For the time metadata values, we can get the full set of metadata values
% and then subscript in the correct months based on the seasonality of the
% site.
timeMeta = {'Jan','Feb','March','April','May','June','July','Aug','Sep','Oct','Nov','Dec'};

% So for each site
for s = 1:numel(F)

    % We're going to call the getStateIndices method for the corresponding
    % instance of the vslitePSM
    F{s}.getStateIndices( ensMeta, Tname, Pname, timeMeta(season{s}) );
end

%% Anything else

% For many DA problems, we might be done building the PSMs. But each PSM is
% different, and some need additional steps before they are ready.
%
% Again, every PSM is different. Some will need additional steps and some
% will not. It is your responsibility to know how to use your PSMs.
%
% For vslitePSMs, I can scroll to the bottom of the documentation and see
% that there is an additional step before running the DA.
%
% Essentially, VS-Lite standardizes
% ring widths before outputting them. To ensure that we use a consistent
% standardization during all time steps and all updates, we need to
% pre-determine a mean and stadard deviation to use for standardization.
%
% vslitePSMs do this by runnning the PSMs once on the initial ensemble, and
% then saving the mean and standard deviation of those widths for all
% subsequent standardizations.
%
% This is done via the "setStandardization" method.

% So to do this step, I will need to run "setStandarization" for each
% instance of the vslitePSMs. Remember, that "setStandardization" is a
% method, not a function, so I will need to run it using dot indexing.

% So, for each site
for s = 1:numel(F)
    
    % I'm going to give its PSM the initial model ensemble and tell it to
    % pre-determine the standardization.
    F{s}.setStandardization( M );
end

% And that's it for the VS-Lite PSMs!

%% Wrapping up

% If you mostly understand this code, and would like to reference it
% without scrolling through 300 lines of discussion, the script
% ntrend_tutorial4_justthecode.m contains this demo with minimal commments.

% PSMs are tricky and varied. If you are interested in understanding them
% in greater detail, you might want to try building a PSM. Please see the
% PSM Development Tutorial for more details.