%% Tutorial 2: Building state vectors
clearvars;

%% Introduction
% Our model data is now organized into a grid file. This is a general
% container that we can use for multiple assimilations.
%
% For a specific assimilation, we will need to specify which portion of the
% data we want to use. This is done by creating a special object that
% contains instructions on how to build a state vector from a .grid file. 
% In the dash package, these design instructions are stored in a special
% object of the "stateDesign" class.

% As with the "gridFile" class, you can see a reference page for
% stateDesign using
%
% >> doc stateDesign
%
% Again, I have listed the essential functions at the top. To see help for
% any of these functions do
%
% >> doc stateDesign.functionName
%
% >> help stateDesign.functionName
%
% Or click on the hyperlink on the stateDesign reference page.

% Unlike the "gridFile" class, which was just a container for a set of
% fileIO functions, the stateDesign class describes unique variables, each
% describing a unique set of instructions used to build a state vector.
% Thus, we will usually treat stateDesigns like variables. However, they
% are a bit more complex than variables, because they also have some functions
% associated with them. From this point onward, I will refer to individual 
% stateDesign variables as "stateDesign objects", and their associated
% functions as "methods". 
%
% If it's useful conceptually, you can think of each stateDesign object
% as an extra-fancy "struct", and the use of dot-indexing is also similar
% to struct syntax.

%% Create a new stateDesign object

% So, let's start by designing a state vector that contains the summertime
% mean (JJA) of sea level pressure at each LME node in the northern
% hemisphere, and the global summertime mean sea level pressure.

% We will start by initializing a new stateDesign object. We'll give it a
% name "My tutorial design"
design = stateDesign('My tutorial design');

% So, "design" is the name of a unique stateDesign object
%
% If we look at it in the console
% >> design
%
% we can see it has the name "My tutorial design", and some other fields
% which are mostly empty.

% For demonstration purposes, we can make a second design
design2 = stateDesign('A different design');
disp(design2);

% Which stores a different value in the "name" field, and if we look in the
% Matlab workspace, we can see that things are distinct objects. Again,
% these are similar to extra fancy structure arrays.
clearvars design2;

% However, one way that the stateDesign objects differ from stucts is that
% they have specific functions associated with them, known as methods.
% Use dot-indexing to apply a method to a specific stateDesign object.

%% Add a variable

% So, one of the essential stateDesign methods is "add". This adds a new
% variable to a state vector. Let's use it to add a new variable to the
% specific "My tutorial design" set of instructions.
%
% You can get help on this specific method via
%
% >> doc stateDesign.add
% >> help stateDesign.add
%
% OR by referencing a specific stateDesign objects, e.g.
%
% >> doc design.add
% >> help design.add

% Here we can see that "add" accepts 2 inputs, the name of the variable,
% and the grid file in which the variable is located.
design = design.add( 'PSL', 'tutorial.grid' );

% So this say, add a new variable to design. The variable's name is 'PSL',
% and it is located in 'tutorial.grid'.
%
% Note that the updated design is provided as output. The command
%
% >> design.add( 'PSL', 'tutorial.grid')
%
% wouldn't actually do anything to design. It would instead return an
% updated design that Matlab would automatically name "ans".
%
% This is to allow multiple state vector designs to be branched off from
% some base set of instructions.


%% Edit the design 

% As a reminder, we want our state design to contain the JJA mean of PSL in
% the northern hemisphere, and the global mean JJA PSL.

% Let's start with the JJA mean in the northern hemisphere. We need to
% provide instructions on what to select. Do this with the "edit" method.

% We'll need to note which indices to extract data from along each
% dimension in the .grid file. Some metadata might be useful. To get .grid
% file metadata use
meta = gridFile.meta('tutorial.grid');

% We can see that meta has a field for each dimension. And each field
% contains the metadata for the dimension.

% Lets get all the northern hemisphere latitudes and the starting index of
% each JJA mean (so, all of the Junes)
nh = meta.lat > 0;
june = month( meta.time ) == 6;

% We are almost ready to edit the design, but first, an important concept:
% In this tutorial, I will refer to "state dimensions" and "ensemble
% dimensions". A state dimension is a dimension for which the metadata at
% each state vector element is fixed. An ensemble dimensions is one for
% which metadata is unique to each ensemble member. Say I have a model
% ensemble:
%
%            1    2    3  ...  M
%     E1  |
%     E2  |
%     ... |
%     En  |
%
% This is an ensemble with M ensemble members, and N state vector elements.
% Say that the state vector is some spatial grid, and the ensemble members
% are selected from different time points.
%
% Then, the spatial dimensions will be state dimensions. State element 1
% will refer to the same lat-lon point in all ensemble members. State
% element 2 will refer to a different lat-lon point, but it will be the
% same point in all ensemble members. And so on...
%
% By contrast, time will be an ensemble dimension. Ensemble member one is
% selected from time point 1, ensemble member 2 is selected from time point
% 2, etc. Note that the time metadata at state vector element 1 is
% undefined -- it depends on which ensemble member you are looking at.

% When editing a state design, you first note which variable you are
% editing, which dimension in the variable you want to edit, and whether
% that dimension is a state dimension or an ensemble dimension.
%
% stateDesign initializes all dimensions as state dimensions by default, so
% you will need to note all the dimensions that are ensemble dimensions for
% your data.

% So, back to the example. Let's first do the northern hemisphere
design = design.edit( 'PSL', 'lat', 'state', 'index', nh );

% Next, we need to note which variable this is in the grid file
design = design.edit( 'PSL', 'var', 'state', 'index', 2 );

% This says: edit the PSL variable, edit the lat dimension, the lat
% dimension is a state dimension, the state vector should be built from the
% data at these lat indices.

% Now, the jja mean
design = design.edit( 'PSL', 'time', 'ens', 'index', june, 'mean', [0 1 2] );

% This says: edit the PSL variable, edit the time dimension, the time
% dimension is an ensemble dimension, build the state vector using data
% that starts at june, but take a mean over june + 0, 1, and 2 subsequent
% time indices (so, june, july and august).

% Also recall that we added in 2 runs to the .grid file. So we also need to
% note that the run dimension is an ensemble dimension
design = design.edit( 'PSL', 'run', 'ens' );

% Now, recall that we also want the PSL global mean in JJA. The dash
% package defines variables as elements with a unique set of instructions
% in a stateDesign. So, even though the global mean PSL is derived from the
% same climate model variable as the NH JJA mean, it is treated as a 
% distinct variable in the state vector (because the instructions regarding
% spatial dimensions will be different).
%
% Let's add this variable, and then edit it in the design
design = design.add( 'PSL_globe', 'tutorial.grid' );
design = design.edit( 'PSL_globe', 'time', 'ens', 'index', june, 'mean', [0 1 2] );
design = design.edit( 'PSL_globe', 'lat', 'state', 'mean', true );
design = design.edit( 'PSL_globe', 'lon', 'state', 'mean', true );
design = design.edit( 'PSL_globe', 'run', 'ens');
design = design.edit( 'PSL_globe', 'var', 'state', 'index', 2 );

% And we're done! Note that the syntax for means is different in state
% dimensions and ensemble dimensions. State dimensions have a simple
% true/false, whereas ensemble dimensions require the indices used to
% compute the mean.

% If we wanted, we could instead use a weighted spatial mean. Say we knew
% the area in each grid node and wanted to weight by it.

% (Here, I'm just undoing the previous mean)
design = design.edit( 'PSL_globe', 'lat', 'state', 'mean', false );
design = design.edit( 'PSL_globe', 'lon', 'state', 'mean', false );

% And here I'm specifying to use a weighted mean
gridArea = rand( 96, 144 );
design = design.weightedMean( 'PSL_globe', ["lat","lon"], gridArea );

% Note that before providing the weights, we needed to specify the order of
% the dimensions in the array of weights.


%% Sequences
% One other concept is a sequence. A sequence is a way for an ensemble
% dimension to have some metadata structure along the state vector.
% (Separate from the metadata for each ensemble member.)
%
% For example, say I wanted to use PSL in the northern hemisphere, but for
% J, J, and A in each month -- without a time mean. My ensemble would look
% something like:
%
%                   1    2    3  ...  M
%     June E1  |
%     June E2  |
%     June E3
%     ...      |
%     July E1  |
%     July E2  |
%     July E3  |
%     ...      |
%     Aug  E1  |
%     Aug  E2  |
%     Aug  E3  |
%     ...      |

% Now, each ensemble member is still associated with a unique time point.
% However, each state vector element is also associated with some time
% metadata (namely, June, July or August). This is referred to as a
% sequence. The syntax for sequences is similar to the syntax for means
% in ensemble dimensions. Note a reference index for the sequence 
% (in this case June), and then the number of indices to progress from that
% reference to contstruct the sequence.
%
% So using our example
design = design.edit( 'PSL', 'time', 'ens', 'index', june, 'seq', [0 1 2], 'meta', ["June";"July";"August"] );

% Note that you MUST provide metadata for sequences. 

% It's also convenient to note that the reference index for a sequence does
% not need to be the actual start of the sequence. Instead of line 233, we
% could instead do
january = month( meta.time ) == 1;
design = design.edit( 'PSL', 'time', 'ens', 'index', january, 'seq', [5 6 7], 'meta', ["June","July","August"] );

% and get exactly the same result.

%% A sequence of means.

% Finally, the most complicated formulation. You may wish to take a
% sequence of means. Perhaps you are studying the effects of volcanic 
% eruptions and want to look at the JJA mean of PSL in year 1, year 2, and 
% year 3. This is a sequence (year 1, 2, 3) of means (JJA). 
%
% In this syntax, the sequence indices refer to the indices from which to
% start counting the mean indices. So do:

design = design.edit( 'PSL', 'time', 'ens', 'index', june, 'seq', [0, 12, 24], 'mean', [0 1 2], 'meta', ["Year 1","Year 2", "Year3"] );

% Here, the reference indices will be june for some ensemble member. To
% make the sequences, we will get reference indices that are 0 time steps,
% 12 monthly time steps (1 year), and 24 monthly time steps(2 years) from
% the reference. Then, from indices 0, 12, and 24, take a mean over the
% next +0, +1, and +2 time indices (JJA year 1, JJA year 2, JJA year 3).

% As before, the reference indices are flexible. The line
design = design.edit( 'PSL', 'time', 'ens', 'index', january, 'seq', [0 12 24], 'mean', [5 6 7], 'meta', ["Year 1","Year 2","Year 3"]);

% would produce the same results.

%% Copying

% As you add more and more variables to a state vector, it can get tedius
% to edit each individual dimension.
%
% If this is the case, check out the "copy" method, which copy and pastes
% design instructions between variables.

% When using copy, note that reference indices (those following the 'index'
% flag) are matched via .grid file metadata, so don't worry if the
% dimensions have different lengths.
%
% There's an example of this at the very beginning of the next tutorial.