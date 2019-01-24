% This is a demo for designing a state vector.

% Please read the State Vector Design Documentation before using. 

% I suggest placing breakpoints at lines: 

% This is our data. It has dimensions of lat x lon x time x run x lev in no
% particular order. For the demo, we're going to pretend that the user is
% not aware of the lev dimension to illustrate that the code can process
% unknown singleton dimensions.
file = 'Ttest.mat';

%% Initialize

% Create a new state vector design. This is a custom container that holds
% all the parameters
design = stateDesign('For NTREND Expt');


%%  Add a variable to the design

% Add and initialize a variable in the design
design = addVariable(design, file, 'T: June');

%% Design the variable.

% Let's do Northern Hemisphere temperature in June

% By default, all dimensions are set as state dimensions with indices at
% all possible indices. For lon, this is completely correct.

% But not the other dimensions. Start by restricting lat to the NH
meta = metaGridfile(file);
latNH = meta.lat > 0;

design = editDesign(design, 'T: June', 'lat', 'state', latNH);
% (Edit the lat dimension of the T: June variable. The lat dimension is a
% state dimension and here are the NH indices to use...)

% Pretty easy. Now, on to the ensemble dimensions. The run dimension is
% easy, we're fine selecting from any run, so we just need to note that run
% is an ens dimension.
design = editDesign( design, 'T: June', 'run', 'ens');

% Finally, time is an ensemble dimension, but we only want to select from
% June time points.
june = month(meta.time)==6;
design = editDesign( design, 'T: June', 'time', 'ens', june);

% Aaaaand we're done! We now have design parameters for a state vector that
% consists of T in the following lat values
disp( meta.lat( design.var.indices{3} ) );

% Selected from the following time points.
disp( meta.time( design.var.indices{5} ) );

% Don't worry about the "design.var.indices{5}" etc. It's part of the
% design structure, but not something the user is expected to know. I'm
% just calling it for the purposes of this demo.

%% Create a sequence

% Now let's do a state vector with a different variable. This time, instead
% of just June, we want the mean summer temperature from J, J, and A. Still
% in the NH.

% Create a design and initialize the variable
design = stateDesign('new Design');
design = addVariable( design, file, 'T: JJA');

% Lat and run are the same
design = editDesign(design, 'T: JJA', 'lat', 'state', latNH);
design = editDesign( design, 'T: JJA', 'run', 'ens');

% But we need to specify the time trajectory over which to take the summer
% mean. The ensemble indices should only point to the start of the mean,
% not the entire collection of the mean. The mean indices will point to the
% collection over the mean.
meanDex = [0,1,2]; 
design = editDesign( design, 'T: JJA', 'time', 'ens', june, 'mean', meanDex );

% Aaand we're done. 

% We'll take a mean
if design.var.takeMean(5)
    disp(['Taking a time mean.', newline]);
end
% Here's an example three points that we might take the mean over
disp( meta.time( design.var.indices{5}(1) + design.var.meanDex{5} ) );

%% Take mean over state dimension.

% We can also take a mean over a state vector. Let's say we wanted the
% NH spatial mean temperature over the summer. Then we could do
design = editDesign( design, 'T: JJA', 'lat', 'state', latNH, 'mean');
design = editDesign( design, 'T: JJA', 'lon', 'state', 'all', 'mean');

% We can see that the state vector will consist of T at the lat values:
disp( meta.lat( design.var.indices{3} ) );
disp( meta.lon( design.var.indices{4} ) );

% And will take a mean
if design.var.takeMean(3)
    disp(['Taking a lat mean.',newline]);
end
if design.var.takeMean(4)
    disp(['Also taking a lon mean.', newline]);
end

%% Do a sequence.

% Alright, we're going to change it up again. Now, instead of doing mean
% JJA, we want J, J, and A individually in each state vector. So we'll want
% a sequence of months instead of a mean.

% Get rid of the mean
design = editDesign( design, 'T: JJA', 'time', 'ens', june, 'mean', 0 );

% Get a sequence instead
design = editDesign( design, 'T: JJA', 'time', 'ens', june, 'seq', [0 1 2] );

% Here's a sample sequence we might draw
disp( meta.time( design.var.indices{5}(1) + design.var.seqDex{5} ) );

% Same as the example mean sequence, except now there is no mean being
% taken.

%% Do a sequence of means. 

% Let's say we're looking at 3-year trajectories of summer (JJA) means.
% What would this look like?

% Make a design and variable
design = stateDesign('new design');
design = addVariable(design, file, 'T: 3 JJA');

% The sequence will start in a June. (So June is the ensemble index). Then,
% each sequence member will be spaced 12 time points (months) apart. So the
% sequence will be 0, 12, and 24 for june in years 1, 2, and 3. Finally, we
% want to take a mean over each june and the following two months. So the
% mean indices will be 0, 1, and 2.
design = editDesign( design, 'T: 3 JJA', 'time', 'ens', june, 'seq', [0, 12, 24], 'mean', [0, 1 2]);

% So here's the time points of a sample state vector. Each row is a
% sequence member and the columns in each row show the time points over
% which a time mean is taken.
showTime = datetime(zeros(3,3), 1,1);
for k = 1:3
    showTime(k,:) = meta.time( design.var.indices{5}(1) + design.var.seqDex{5}(k) + design.var.meanDex{5} );
end
disp(showTime);


%% Couple a second variable.

% Let's say we want two variables our state vector. Let's do T and P in the
% NH in June. Start by adding the T variable.
design = stateDesign('new design');
design = addVariable(design, file, 'T: June');
design = editDesign( design, 'T: June', 'lat', 'state', latNH );
design = editDesign( design, 'T: June', 'time', 'ens', june);
design = editDesign( design, 'T: June', 'run', 'ens');

% We now want to create the P variable. But, we want to make sure that P is
% drawn from the SAME time and run as T. That way, it's not from some
% completely different climate state. We need to couple P and T so that
% they are always drawn from the same ensemble indices.
design = addVariable( design, file, 'P: June');
design = coupleVariables( design, 'P: June', 'T: June' );

% And we're done! By default, coupling two variables syncs their state,
% ensemble, sequence and mean indices. We can check the latitude values for
% P to see that it is indeed restricted to the Northern Hemisphere
disp( meta.lat( design.var(2).indices{3} ) );

%% Edit coupled indices.

% Any indices that are coupled between variables are synced to one another.
% So if you change a coupled index for one variable, it will change for the
% other.

% So, for example, let's change the T lat indices to the southern
% hemisphere
design = editDesign( design, 'T: June', 'lat', 'state', ~latNH );

% We can now look at the P latitude indices and see that they have also
% changed to the Southern Hemisphere.
disp( meta.lat( design.var(2).indices{3} ) );


% We could also try changing the month to August
august = month( meta.time ) == 8;
design = editDesign( design, 'T: June', 'time', 'ens', august ); 

% And see that the time indices also change for P
disp( meta.time( design.var(2).indices{5} ) );

%% Uncouple variables.

% If we realize we coupled indices by mistake we can uncouple specific
% indices. Let's try it with state indices.
design = uncoupleVariables( design, {'T: June','P: June'}, 'state' );

% And see that changing T no longer changes P for the latitude dimension
design = editDesign( design, 'T: June', 'lat', 'state', latNH);
disp( meta.lat( design.var(2).indices{3} ) );

% But still syncs the ensemble indices
design = editDesign( design, 'T: June', 'time', 'ens', june );
disp( meta.time( design.var(2).indices{5} ) );

% We could also just completely uncouple all indices for the variables
design = uncoupleVariables( design, {'T: June','P: June'} );


%% Delete a variable

% Just going to shoe horn this in. Let's say we used the wrong file for P.
% We should delete the P variable from the design and try again
design = deleteVariable( design, 'P: June' );


%% Coupling variables with different metadata values.

% Some coupled variables may only have partially overlaping metadata. When
% this is the case, coupleVariables restricts ensemble indices to ONLY the
% overlapping metadata for the two variables. 

%% Couple a variable with different state indices.

% Let's say we want to do T and P variables, but T only for the NH, and P
% for the whole globe. We'll still want to couple T and P, but we shouldn't
% couple their state indices. This can be accomplished with a simple flag.
design = addVariable(design, file, 'P: globe');
design = coupleVariables( design, 'P: globe', 'T: June', 'nostate');

% We can see that T is NH
disp( meta.lat( design.var(1).indices{3} ) );
% While P is global
disp( meta.lat( design.var(2).indices{3} ) );

% Similar flags hold for coupling ensemble, mean, and sequence indices.

%% Coupling variables with sequences.

% Recall that coupled variables have the same ensemble indices AND that
% ensemble indices indicate the START of sequences. This can be important
% to keep track of. Let's say we wanted a state vector with the
% January-December annual mean T, and also a JJA T.

% The start of the annual mean is in January, so we will need to use
% January as the ensemble index. However, this means that june will no
% longer be the reference index for the JJA sequence; instead, january will
% be the reference index. We will need to adjust the sequence index for JJA
% from [0, 1, 2] to [5, 6, 7] to account for the 5 month shift in the
% reference index.

january = month(meta.time)==1;

% Initialize the design and variables
design = stateDesign('new design');
design = addVariable(design, file, 'T Ann');
design = addVariable(design, file, 'T JJA');

% Edit indices
design = editDesign( design, 'T Ann', 'run', 'ens' );
design = editDesign( design, 'T Ann', 'lat', 'state', latNH );
design = editDesign( design, 'T Ann', 'time', 'ens', january, 'mean', [0:11] );

% Couple. Don't couple sequence or mean indices.
design = coupleVariables( design, 'T JJA', 'T Ann', 'noseq','nomean');

% Edit indices
design = editDesign( design, 'T JJA', 'time', 'ens', january, 'seq', [5 6 7] );
