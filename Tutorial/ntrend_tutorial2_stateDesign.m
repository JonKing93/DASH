%% This tutorial shows how to run dash for NTREND using the VS-Lite forward
% model and CESM-LME temperature and precipitation output for the months
% May - September.
%
% This is the second module in the tutorial and focuses on state vector
% design.

%% Introduction

% So, as heavily emphasized in the File IO module, .grid files are not
% intended to hold the data for a specific DA analysis. Rather, they are a
% formatted, MATLAB-readable data collection intended for multiple
% analyses.

% But now that we have our .grid file, it's time to start focusing on a
% specific analysis. But how to select specific data?

% In short, we will do this by creating an object that holds instructions
% on how to select data from the .grid files. This object is an instance of
% the "stateDesign" class. Essentially, it tells dash how to build a state
% vector in a model ensemble.

% The stateDesign class is a special array that holds design parameters for
% each variable in a state vector. (A note on syntax here: when I refer to a
% variable in a state vector, I am referring to the collection of all
% temperature (T) elements, or all precipitation (P) elements. I am not
% referring to a specific element such as temperature at latitude 5,
% longitude 20. I would refer to that as a state vector element or a T
% element.)

% So, for each variable in the state vector, we will need to provide some
% sort of information that tells how to extract a state vector from the
% .grid files. For dash, we will do this by specifying which data indices
% should go into the state vector, and which data indices should be used to
% create different ensemble members. We will do this using the metadata in
% the .grid files, and this is one reason why we spent so much time on 
% metadata in the previous tutorial metadata. Essentially, the metadata is
% what we will use to design a state vector.

% So let's introduce two new terms:
% 1. State dimensions, and
% 2. Ensemble dimensions

% We already talked about data dimensions in the file IO module, these are
% things like 'lat','lon','lev','run', and 'time' and are specific
% dimensions of the gridded dataset. "State" and "Ensemble" are two
% categories we can use to divide these dimensions. Essentially, the term
% "state" and "ensemble" refers to how each dimension's metadata appears in
% a state vector.

% A state dimension is a dimension for which the metadata value of an
% in a state vector is unchanging in each ensemble member.

% So, for example, say I created a small state vector consisting of
% temperature at lat = 5, lon = 20; and of temperature at lat = 6, 
% lon = 25. I then create a 30 member ensemble of this state vector by
% extracting temperature at these two points from various time steps.
%
% In this example, lat and lon are state dimensions. In every ensemble
% member, the first element of the state vector is from lat = 5. And in
% every ensemble member, the second element of the state vector is from
% lat = 6. The metadata at these elements is unchanging in each ensemble
% member, so lat is a state dimension. So in lon, by a similar argument.
% 
% Note that lat and lon don't need to have the same value at EVERY element 
% in order to be state dimensions. They just cannot change value for each
% individual element.

% So what about ensemble dimensions? Ensemble dimensions have a different
% metadata value for each ensemble member. They are the dimensions from
% which different ensemble members are selected.
%
% So in the example above, I said that we created a 30 member ensemble by
% extracting the temperature values from 30 different time steps. In this
% example, time is an ensemble dimension. Each ensemble member will have a
% different metadata value for time (e.g. time step 1, time step 2, ...
% time step 30).
%
% Just a quick note, state and ensemble dimensions are unique to each
% variable. In most applications, they will be exactly the same for each
% variable (more on this later), but dash allows different variables to
% utilize different state and ensemble dimensions.

% So to create a state vector design, we will first need to inform dash whether
% each dimension is a state dimension or ensemble dimension. We will then
% provide information on which state dimension elements we should use in
% the state vector, and which ensemble dimension elements we should use to
% select ensemble members. 

% We will do this using the functions:
% stateDesign
% addVariable
% editDesign

% We will use the "stateDesign" function to initialize an empty
% stateDesign. The addVariable function will add our variables (T and P) to
% the design. The "editDesign" function is the workhorse of the state
% design, and will be use to specify whether dimensions are state or
% ensemble dimensions and which indices to use. So, let's get started!

%% Initialize stateDesign

% So, we will need to initialize an state vector design. We will also need
% to name our state vector design. 
d = stateDesign('My NTREND Expt');

% So this line says, create a state vector design, d. It's name is "My
% NTREND Expt". If we want to look at the design, we can do
dispDesign(d);
% and see the name.

% If you're curious about the inner working of the stateDesign, we can do:
disp(d);

% You should see a stateDesign object with the name 'My NTREND Expt', an
% empty array of variable design parameters (var), an empty array of
% variable names (varName), and some under-the-hood values that have to do
% with synced and coupled variables. You do not need to know about synced
% and coupled variables now, and we will talk about them in detail later in
% this tutorial.
%
% As a user, you do not need to know anything at all about the inner
% workings of the state design. Any changes to the design will be done
% through the editDesign function. But if you are interested in
% understanding the design in greater detail, please see the advanced
% documentation.

%% Add a variable

% Alright, let's recall our application. We want to do DA on:
% NTREND using the VS-Lite forward model for May - September.

% VS-Lite needs two climate variables to run: temperature (T), and
% precipitation (P). Thus, we will need to add temperature and precipitation
% to our state vector. Conveniently, we already have two .grid files holding
% these exact variables, Tref-LME.grid and P-LME.grid.

% Let's start by adding the temperature variable. We'll come back to the P
% variable later when we talk about synced and coupled variables.

% So, to add a variable to a state vector, we need to provide the .grid
% file that holds the file, and a name for the variable. We can use any
% name at all (e.g. 'T', 'temperature', 'thisisthebestvariable_qwerty123').
% Just use whatever name you like for your variable.
d = addVariable(d, 'Tref-LME.grid', 'T');

% So this line says: Here is a state design (d). I want you to add a
% variable to the state design. The data for the variable is inside the
% file 'Tref-LME.grid', and I want you to name the variable 'T'.

% Note that stateDesign objects are not handles, so you will need to get
% the output (d) to get the updated design. If you just did the command
% 
% >> addVariable(d, 'Tref-LME.grid', 'T')
%
% nothing would happen to d.

%% varDesign object

% (This section talks about some of the under-the-hood details about
% stateDesigns. You do not need to know any of this information to use dash
% and can completely skip this section if you are not interested.)

% So, our state design now contains one variable T. If you're curious, you
% can look at
dispDesign(d);

% If you want to see the code structure, we can do
disp(d);
%
% And see that it now contains some design parameters for a variable (var)
% in the form of a varDesign object. You can also see that the variable's
% name (varName) is "T".
%
% The varDesign object holds all the information on the dimensions of T, as
% well as information about the .grid file for T, and the T metadata. You
% do not need to know anything at all about the varDesign to use dash, but
% I'll talk about some of the details as part of this tutorial. This way,
% you can manually review a state vector design if you ever want to in the
% future.

% So let's take a look at the varDesign. (Again, you will never actually
% need to do this for dash, so you can skip this if you want.)
disp(d.var)

% You should see a varDesign object with a number of properties. The first
% 5 should be familiar. The are, the name of the variable, the .grid file
% that contains the variable data, the order of dimensions in the .grid
% file, the size of each dimension, and the metadata associated with the
% .grid file. We've already talked about these in detail in the File IO
% module.

% The next field is a logical that specifies whether each dimension is a
% state dimension or an ensemble dimension. The ensMeta field provides
% metadata values for ensemble dimensions (more details on this later).

% Indices is a very important field, it contains the set of indices used to
% build the state vector, or used to select ensemble members.

% The next two fields, seqDex and meanDex, hold indices used for creating
% sequences or taking means on ensemble dimensions. We will discuss
% sequences and means in detail later in this tutorial.

% takeMean and nanflag hold instructions on whether to take a mean along a
% particular dimension, and whether to include or omit nan values.

% Finally, overlap is a switch that specifies whether non-duplicate,
% overlapping ensemble sequences are allowed in the model ensemble. That
% probably sounds like tech-babble right now, but it should make sense by
% the end of the tutorial.

%% Edit a state dimension

% So, we have our stateDesign, d, which holds a variable "T". We should
% start providing instruction on which data elements to use in each state
% vector.
%
% Let's start with latitude. Since we're looking at NTREND, let's limit our
% DA to the Northern Hemisphere (NH). So, we need to tell dash which elements in
% the .grid file are in the NH. Fortunately, we conserved all our metadata
% when we built the .grid files, and can look at it now using the
% metaGridfile function.
meta = metaGridfile('Tref-LME.grid');

% Let's look at the metadata just to recall what's in it
disp(meta);

% We can see that the metadata holds lon, lat, lev, time, and run metadata.
% For now, we want to work with the lat metadata. Specifically, we want the
% latitudes greater than 0. Let's get the indices of those elements.
NHindex = meta.lat > 0;

% Alright, we now have the indices of the NH latitude elements in the .grid
% file. Let's tell dash to only use those elements.
d = editDesign(d, 'T', 'lat', 'state', 'index', NHindex );

% So, this line says: Here's a state vector design (d). I want you to edit
% the variable named 'T'. I want you to edit the 'lat' dimension of T.
% You need to know that 'lat' is a 'state' dimension. The 'index' flag 
% indicates that the next input will be the state indices for the 'lat'
% dimension. Here are the indices (they are the NH).

% If you're curious, you can look at the "indices" field of the lat dimension
% of variable 'T'
dispDesign(d, 'T', 'lat',true);

% and see the metadata values at the selected indices. You'll notice that
% all are in the Northern Hemisphere.


%% Default state dimensions

% So, that covers latitude. What about longitude and level? They are also
% state dimensions.

% It turns out that we don't actually need to eidt anything in the design for
% these dimensions
%
% By default, dash initializes all dimensions for a variable as state
% dimensions. It also sets the default indices in every dimension to include
% every element in the dimension.
%
% Dash sets these as the defaults in order to account for trailing
% singleton dimensions of which the user is not aware. For example, in the
% File IO module, I mentioned that we didn't actually need to provide any
% 'lev' metadata for dash. This was because both the T and P variables are
% for a single level, they don't actually have any "lev" dimensionality.
% Equivalently, lev is a singleton dimension.
%
% It would be very reasonable for a user looking at these variables to be
% completely unaware of the 'lev' dimension. Their data does not include
% it, so there is no reason for them to know what it is. However, dash
% includes ALL dimensions recognized by dash in .grid files. Even if the
% user is unaware of the 'lev' dimension, dash is aware that data
% sometimes has a 'lev' dimension, and leaves a place for it in the .grid
% file. That space is empty and filled with NaN metadata, but it still
% exists.
%
% A second example is tripolar coordinates in ocean grids. Users working with
% land datasets may be completely unaware of this coordinate system and are
% not expected to provide any tripolar metadata. But some ocean modelers
% may have data in this coordinate system, so dash reserves space in the
% .grid files for tripolar metadata. This dimension is not actually used by
% land modelers, and so the dimension is simply a trailing singleton with
% NaN metadata.
%
% Dash initializes dimensions as state dimensions with all elements
% selected to account for these trailing singleton dimensions. By setting
% them as state dimensions and always using their singleton element, the
% structure of the gridded data is not affected.
%
% (You may be wondering why we don't just delete trailing singleton
% dimensions. The reason is that the user may wish to extend these
% dimensions later. In fact, that's exactly what we did in the file IO
% module. We initialized 'run' as a singleton dimension, but later appended
% new data onto that dimension. If we had deleted the 'run' dimension, we
% could not have appended new data to it later.)

% Coming back to the state vector design. We want to set lon and lev as
% state dimensions and use all their elements in the state vector. For lon,
% this is each longitude point, and for lev this is the singleton surface
% level. Since lon and lev were intialized as state dimensions with all
% indices selected, we're done. Don't need to do anything.


%% Set an ensemble dimension.

% Alright, so those were state dimensions, what about ensemble dimensions?
%
% Let's start with the easy one: run

% The run dimension is an ensemble dimension because we can select climate
% states from different runs to get our ensemble. All the runs are equally
% valid, so we can select from any/all the runs to get correct results. 
%
% As pointed out in the preceding section, all dimensions are intialized as
% state dimensions with all indices selected. The "all indices selected" is
% correct for the 'run' dimension, but we need to change it to an ensemble
% dimension. The flag used to mark a dimension as an ensemble dimension is
% 'ens', so we do
d = editDesign( d, 'T', 'run', 'ens');

% So, this line says: Edit the stateDesign (d). I want you to edit the 'T'
% variable. Specifically, edit the 'run' dimension. The run dimension is an
% ensemble dimension. That is all.

%% Sequences

% Now, ensemble dimensions can be a bit trickier than state dimensions. For
% state dimensions, we use the same values always for each data element.
% That's it, done. But for ensemble dimensions, things may be more complex.
%
% Initially, ensemble indices seem analogous to state indices. They are
% simply the indices that are allowed for selecting ensemble members. If we
% want to do DA on June, we can just provide the indices for June, right?
%
% Not necessarily. What would happen if we wanted to look at JJA
% temperature fields? What would we provide as indices? The indices of J,J
% and A time steps? No, this would select single month ensemble from
% J, J, or A, not the desired result.

% What if we provided the JJA indices, and told dash to select three for
% each state vector? Also bad. We might select three Junes in the same
% state vector, not a JJA.

% Okay, could we provide J, J, and A indices sequentially, and tell dash to
% use one of each to make each state vector?

% Getting closer, but there's still a problem, what if we select June of
% year 5, July of year 17, and August or year 492? That wouldn't be right
% either.

% Instead, what we need to do is provide the indices of June and then tell
% dash to also read data from the two time steps after whichever June is
% selected for an ensemble member. This allows us to draw random ensemble
% members, while still preserving the internal structure of the ensemble
% dimension.

% In dash, I refer to this as specifying a "sequence" for an ensemble
% dimension. Essentially, we will provide the start of each sequence as the
% ensemble indices, and then the set of indices after that starting index
% to add to the state vector.

% For a second example, consider a DA problem where we are drawing a
% spatial ensemble and want the 9-box grid around a random spatial point.
% In this scenario, we would need to provide a lat and a lon sequence to
% define the 9-box grid around the spatial point. The need to
% maintain some structure within the ensemble dimensions creates a
% need for a sequence.

% So, for our application, we want to draw an ensemble for NTREND from
% random time and run elements. So time is an ensemble dimension. But we
% also want to look at May-September, which is along the time axis. So the
% time ensemble dimension has some structure we want to preserve and we
% should use a sequence.

% We'll start by getting the beginning of each sequence, May. These May
% indices are what we'll use as the ensemble indices for the time
% dimension.
MayIndex = month(meta.time)==5;  % Get the indices of time points where the month is 5 (May) 

% Now, we want to create a sequence from May, the starting index (0)
%                                       June, the next index (+1)
%                                       July, the next next index (+2)
%                                       August (+3 time steps)
%                                       September (+4 time steps)

% So, our sequence indices are 0, 1, 2, 3, and 4
seqDex = [0 1 2 3 4];

% Note that we need to include May if we want it in the sequence. The
% ensemble indices ARE NOT the start of extracted data. Instead they are
% the reference index from which sequence indices begin counting.
%
% So, we could do an ensemble index of January
% >> JanIndex = month(meta.time)==5
%
% and a sequence of
% >> seqDex = [5 6 7 8 9];
%
% and get exactly the same result as the code above.
%
% (By default, sequence indices are set to 0. So if your ensemble dimension
% is not a sequence, you can just provide the ensemble indices and be done)

% Finally, we may wish to provide metadata on what the sequence members
% actually are. The metadata for each ensemble member will be different,
% but the internal structure of the sequence may have some associated
% metadata.
%
% So for example, we might have 1884 MJJAS, 1965 MJJAS, 750 MJJAS as three
% different ensemble members. But the May - September structure of the
% sequence always remains the same. So let's provide a metadata value for
% each sequence element.
ensMeta = {'May','June','July','Aug','Sep'};

% Alright, we have our ensemble indices and sequences indices. Let's add
% them to the design
d = editDesign( d, 'T', 'time', 'ens', 'index', MayIndex, 'seq', seqDex, 'meta', ensMeta );

% So, this says: Edit the design d. Edit the T variable. Specifically, edit
% the time dimension of the T variable. The time dimension is an 'ens'emble
% dimension. The next input is the ensemble indices (MayIndex), the next
% input is the sequence index (seqDex), the last input is metadata for the
% ensemble sequence elements (ensMeta).
%
% (An aside: For reasons that will become clear in the PSM module, ensemble
% metadata should generally consist of unique values. So 
% >> ensMeta = {'M','J','J','A','S'}
%
% would not be good because June and July have the same ID (J). Again, the
% reasons for this will become more clear in the PSM module.


%% Coupled and Synced Variables

% Alright, we're done with the T variable! On to P...

% Before we add another variable to the state vector design, we should
% define two terms
% 1. Coupled Variables
% 2. Synced Variables

% Coupled variables are variables that are selected from the same metadata
% values of ensemble dimensions in each ensemble member. For example, let's
% say we're using the VS-Lite PSM. VS-Lite needs two climate variables, T
% and P.
%
% If we are selecting an ensemble member and use May-Sept. of 1884 for T,
% and May-Sept. of 2005 for P, we will get a very wrong result. Instead, if
% T is selected from 1884, P should also be selected from 1884. This is the
% principle of coupling.
%
% In general, most variables are expected to be coupled in a data
% assimilation, so dash couples all variables by default. If you are
% interested in disabling the default coupling, please see the
% documentation.
%
% Also, when variables are coupled, they are set so that they share the same
% state and ensemble dimensions. Dash will notify when the type of a
% dimension is converted by the coupler.

%
% (Note that dash couples variables by matching metadata, not by any
% operation on ensemble indices. So, if you have .grid files with gridded
% data of different sizes, no worries! Don't do anything. Dash
% will search through metadata to find where the metadata of an ensemble
% dimension matches the metadata at the ensemble indices of a coupled 
% variable.)

% Synced variables are a more specialized case of coupling. Synced
% variables are coupled AND share all state, ensemble, sequence, and mean indices. Syncing
% is intended for processing variables on the same grid for a DA analysis.
%
% Again, the .grid files corresponding to synced variables can be different
% sizes. All state and ensemble indices are matched via .grid metadata,
% rather than a naive copying of state and ensemble indices.
% 
% Note that changing the state or ensemble indices of a variable will
% change the indices for all synced variables.

% Finally, note that synced variables are always coupled, buyt coupled
% variables are not required to be synced.

% Alright, let's add P to the stateDesign
d = addVariable(d, 'P-LME.grid', 'P');

% (Add a variable to d. The data for the variable is in P-LME.grid. Name the
% variable 'P'.)

% You can look at d and see that it now contains a second varDesign
disp(d);

% We want P coupled to T, and this is the default, so we don't need to do
% anything for that.
%
% We also need to set all the indices for P. 

% We could do this using the 3
% calls to editDesign that we used for T, but there is a faster way. We can
% note that P is on the same grid as T. Thus, T and P are synced variables.
% We can use the function syncVariables to sync P to T and set all the
% indices of P at once.
d = syncVariables(d, 'P', 'T');

% This says, in the design d. Sync the variables P and T, using the
% metadata values in T as the template for selecting indices in P.

%% Mean Indices

% We're actually done with the NTREND state design, but there's one last
% topic to touch on, so let's modify the NTREND experiment. 

% Now, in addition to T and P, Let's add the spatiotemporal MJJAS mean
% temperature to the end of the state vector.  

% (This is essentially what Steiger et al did with their augmented state
% vectors, albeit with global annual means.)

% We'll start by adding a variable for the monthly means
d = addVariable( d, 'Tref-LME.grid', 'T Mean');

% So: Add a new variable to design d. All the data you will need to
% calculate the variable is in the file Tref-LME.grid. Name the variable 
% 'T Mean'.

% Taking a mean along a state dimension is relatively simple. We just need
% to insert a flag specifying that we should take the mean along this
% dimension. Note that a state dimension can either take the mean along the
% entire dimension, or not at all. If you want a mix of mean of not mean
% values, you will need to specify two variables (exactly as we are doing
% here.)
d = editDesign(d, 'T Mean', 'lat', 'state', 'index', NHindex, 'mean', true);

% So, edit the design d. Edit the variable named 'T Mean'. Specifically,
% edit the 'lat' dimension. The lat dimension is a state dimension. It
% should be sampled from these indices in the Northern Hemisphere. It is
% true that you should take the mean along this dimension.

% We also need to instruct dash to take a mean down the longitude
% dimension.
d = editDesign(d, 'T Mean', 'lon', 'state', 'mean', true);

% Now, as usual, the ensemble dimensions are slightly more complex than the
% state dimensions. Instead of just a true/false switch, we need to tell
% dash a set of indices over which to take a mean. This is very similar to
% the sequence indices. This time, instead of using a sequence with indices
% of [0 1 2 3 4], we are going to instruct dash to take a mean over the
% indices [0 1 2 3 4].
meanDex = [0 1 2 3 4];

% An important technical note: You can combine mean indices with sequence
% indices. In this setup, a mean is taken over the relevant indices
% using each sequence index as a reference.
%
% So this means that ensemble indices provide the reference index from
% which to start a sequence. And sequence indices provide the reference
% index from which to start taking a mean.
%
% For example, you might want to do this if you wanted JJA means for three consecutive
% years. Your sequence indices would be annual, and the mean
% indices would point to June July and August. One possible implementation
% would be
%
% >> ensIndex = month( meta.time ) == 6;
% >> seqIndex = [0 12 24];
% >> meanIndex = [0 1 2]
%
% If you did this, dash would select an ensemble member from month 6 (June)
% It would look at the first sequence element (0) and advance 0 indices.
% So dash is still pointing at June in year 1.
%   Dash would then take the mean at that +0, +1, and +2 timesteps (June,
%   July, and August)
% Then, dash would look at the second sequence element (12) and advance 12
% timesteps to June of year 2.
%   Dash would then take a mean at 12 +0, 12+1, and 12+2 (June, July and
%   August of year 2)
% Finally, dash would advance 24 time steps (the third sequence element --
% June of year 3) and take a mean over June, July, and August of year 3.

% Alright, back to the design. Let's set the indices
d = editDesign(d, 'T Mean', 'time', 'ens', 'index', MayIndex, 'mean', meanDex, 'meta', ensMeta );

% So, edit the design, d. Edit the variable 'T mean', edit the time
% dimension, the time dimension is an ensemble dimension. The ensemble
% indices (the start of sequences) are the indices of May, take the mean
% from May - September. The metadata for this sequence is May-September.

% Now, if you were paying close attention, you might be wondering about the 'run'
% dimension. Shouldn't we declare that it is an ensemble dimension? 

% No. I mentioned that dash couples variables by default, and that coupled
% variables are set to share the same state and ensemble dimensions. 
% When we added T Mean to the state design, it was coupled to T and P, and
% the 'run' dimension (along with the 'time' dimension) was converted to an
% ensemble dimension automatically.

%% Look at the design

% We've already used it a few time, but the dispDesign function allows you
% to look at a design and see key information. You can look at the entire
% design
dispDesign(d);

% A specific variable
dispDesign(d, 'T');

% A specific dimension of a variable
dispDesign(d, 'T', 'lat');

% Or a specific dimension, including the metadata values at the selected
% state or ensemble indices.
dispDesign(d, 'T', 'lat', true);

%% A few final notes

% You may remember the 'overlap' field in the varDesign and notice the 
% "Ensemble Overlap" output in dispDesign. This will be explained in the
% next module.

% Also, if you mostly understand the code and just want a quick reference
% (without scrolling through 600 lines of code)
% you can look at ntrend_tutorial2_justthecode.m
