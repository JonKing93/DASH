%% This tutorial shows how to run dash for NTREND using the VS-Lite forward
% model and CESM-LME temperature and precipitation output for the months
% May - September.
%
% This is the third module in the tutorial and focuses on building an
% ensemble.

%% Overlap

% Alright, so before we talk about ensemble creation, we need to define
% overlap. We saw this term briefly in the last module, where I stated that
% variables have a switch that specifies whether to allow
% "non-duplicate overlapping ensemble sequences".

% Time to unpack that statement.
%
% Recall that we can specify sequences for ensemble dimensions. In the
% previous module, we used sequence indices to instruct dash to extract
% data from May - September for a given ensemble member.
%
% Now, depending on the length of the sequence, it can be possible for
% sequences in different ensemble members to partially overlap. For
% example, we might want to look at sequences of 3 years of monthly data.
% If we specified ensemble indices at each January, we could select
% an ensemble member that contained years 1, 2, and 3  AND a second
% ensemble member that contained years 2, 3, and 4. These sequences would
% overlap and the total amount of novel climate data in the DA would be
% slightly reduced.

% By default, dash does not allow the selection of overlapping sequences.
% However, you can change this if need to. (Perhaps you want to examine very
% long sequences, create a very large ensemble, or simply have a small
% amount of model states to work with.) To see how to allow overlap, please
% see the advanced documentation.

%% Build an ensemble

% Alright, we are now ready to build an ensemble!
%
% This is actually very easy. We did all the work when we created the state
% vector design. Now we can simply provide the design and an ensemble size,
% and let the method run. The outputs will be the ensemble of model state
% vectors, M; and ensemble metadata. The ensemble metadata will contain the
% variable name and metadata values for each dimension of each element in
% the state vector. This metadata will be used to create PSMs in the next
% module.

% So, to create the model ensemble, do:
nEns = 1000;
[M, ensMeta] = buildEnsemble(d, nEns);

% So, this says: Build an ensemble of model state vectors using the
% instructions in the stateDesign d. The ensemble should have 1000 members.

%% Notes on NaN

% Some notes about the ensemble creation process. Reading all the
% information from the .grid files into the state vector ensemble can take
% a bit of time.
%
% It would be very irritating if the method took a long time to build most
% of the ensemble, then encountered an error (such as realizing that it is
% impossible to select the desired number of ensemble members), and
% consequently lost all the previous work.
%
% Thus, the ensemble builder does not begin extracting any data until until it is
% has selected all of the ensemble members.

% One consequence of this design is that the ensemble builder cannot check
% for NaN values in a state vector until it has already begun creating
% the state vectors (at which point it is unable to select different ensemble
% members).
%
% Thus, it is possible for the ensemble builder to create a state vector
% that contains a NaN element.
%
% However, NaN elements are not permissible for data assimilation, so the
% ensemble builder will toss out state vectors with NaN elements. Thus it
% is possible for a "1000 member ensemble" to actually contain slightly
% less than 1000 members. Dash will notify the user when this occurs, and
% good state vector design should help mitigate this.
%
% This will probably change in Dash V2.

%% Ensemble metadata

% So, what does the ensemble metadata look like?

% (If you are just using dash with pre-built PSMs, you don't need to know
% this. But if you are interested in eventually building PSMs, this is
% useful.)

% Let's first look at the size of the actual ensemble
disp( size(M) );

% We can see that the ensemble is a collection of state vectors with 69121
% elements. And there are 1000 ensemble members of these state vectors.

% If we look at the ensemble metadata
disp( ensMeta );

% We can see that the ensemble metadata consists of a metadata value for each
% dimension (and also the variable name), of each element in the state
% vector. For example, if we look at the variable names
disp(ensMeta.varnam);

% We can see it is a list of 69121 names. The first 34560 names are "T"
% (48 lat x 144 lon x 5 time). The second 34560 names are "P", and the
% final name (1 lat mean x 1 lon mean x 1 time mean) is "T Mean".

% Similarly, we can look at lat
disp(ensMeta.lat);

% Here we can see that each lat metadata value holds the latitude for a
% specific element of the state vector. The first 34560 lat ensemble
% metadata values cycle from 0 to 90, 144 times (once for each lon point) x 
% 5 times (once for each time point).
% 
% The next 34560 lat values are the same (they are the same lat values, but
% now for the P variable instead of the T variable.)
%
% However, the last lat metadata value (the one for the "T Mean" variable)
% looks a bit different. It is a cell containing 48 members. If we look
% inside this cell
disp( ensMeta.lat{end} );

% We can see that the ensemble metadata holds the 48 latitude values over
% which we took the meridional mean.

% A similar story holds for lon. If we look at the metadata for lon
disp( ensMeta.lon );

% We can see that it cycles through longitude metadata for each lat, and
% time point for the first two variables. Then, the last metadata value is
% a collection of 144 metadata values. These are the values over which we
% took the zonal mean.

% This is also one reason why ensemble metadata is stored in cells. There
% may be a different number of metadata values for each state vector
% element, so we need to use cells in order to concatenate everything.
%
% (The other reason is that different .grid files may use different types
% of metadata for the same dimensions. We want to allow this, and storing
% everything in cells also allows concatenation of different data types.)

%% Ensemble metadata of ensemble dimensions

% So far, we've looked at the ensemble metadata of state dimensions (lon
% and lat). This metadata was extracted from the metadata we provided when
% we first built the .grid files.

% But, the ensemble metadata of ensemble dimensions is a bit different.
% The metadata from the .grid file would change for each ensemble member,
% so it would be hard to use grid metadata to describe each state element.

% Instead, recall that we provided ensemble metadata when we designed the
% state vector. Specifically, the ensemble metadata for the time dimension
% was 
% {'May', 'June',' July', 'Aug', 'Sep'}
% 
% This was the metadata we provided to dash that describes the structure of
% the sequences in the ensemble dimension.
%
% (Also recall that we didn't provide any metadata for the 'run' ensemble
% dimension because it had neither sequences indices nor mean indices.)
%
% So that is the difference in metadata for ensemble dimensions. The
% metadata is constructed from the ensemble metadata input during state
% vector design, rather than .grid metadata.

% Let's look at the 'run' dimension metadata
disp( ensMeta.run );

% We can see that, since we didn't provide any ensemble metadata for run,
% the metadata values were all infilled with NaN.

% Now let's look at the ensemble time metadata
disp( ensMeta.time );

% Here we can see that the first 69120 values cycles through the values
% 'May', 'June', 'July', 'Aug', and 'Sep' depending on the time step of the
% state element. 
%
% We can also see that the very last element (the "T Mean" variable) is a 5
% element cell. Looking inside
disp( ensMeta.time{end} );

% we see that it contains the 5 metadata values over which we took the time
% mean.

