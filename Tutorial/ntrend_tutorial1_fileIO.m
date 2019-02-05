%% This tutorial shows how to run dash for NTREND using the VS-Lite forward
% model and CESM-LME temperature and precipitation output for the months
% May - September.
%
% This is the first module of the tutorial and focuses on File IO.
%
% Note that this module processes 3 variables from 12 LME runs (~20 GB of
% data) and will take a little while to run. I'd estimate ~20 minutes,
% depending on the power of your computer.

%% File IO

% To start this analysis, we first need to move our data out of the LME
% output files and into MATLAB.
%
% These data are very large, so we don't want to store them in active
% memory. Instead, we'll save them to file.
%
% To save these data in an optimal way for dash, we're going to use the
% functions: 
% buildMetadata
% newGridfile
% extendGridfile
% 
% This will save the data in .grid files. (These are just a .mat file with a
% different extension.) In addition to actual output variables, the .grid
% files also store metadata that will be useful later in dash.
%
% The metadata in a .grid file is saved in a special structure that will
% allow several under-the-hood functionalities. You do not need to know
% what these functions are nor do you need to worry about making the
% metadata structure. That is what the "buildMetadata" function is for; it
% converts metadata into something that dash can use.
%
% After getting the metadata, we will load in some data and create a new
% .grid file that will store that data. This is what "newGridfile" is for.
%
% Now, LME has 12 (uncorrupted) model runs. This is a lot of data and is too big to hold
% in working memory. To save it all to a .grid file, we will want to load
% in the data for a particular run, extend the .grid file to include
% another run, and then save the new data. This is what "extendGridfile"
% does.

%% Build Metadata

% We'll start by building this metadata structure for LME Temperature
% output. We're going to read out the metadata from LME .nc output files.
% We'll also need to provide the size of the gridded data, and the
% ordered names of the data dimensions. This is so that dash can check and
% ensure it has metadata for every data element. Finally, we'll need to
% tell dash the name of this variable. This can be anything at all,
% whatever you prefer is fine.

% So, here is an LME output file for TREFHT.
% We'll start by extracting latitude and longitude and level metadata. The
% run is not recorded in the .nc file, but I know this is run 2 because of
% the .002 in the file name.
file1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
lat = ncread(file1, 'lat');
lon = ncread(file1, 'lon');
run = 2;

% We'll also want to extract time metadata. LME splits its output into
% pre-1850 and post-1850. So we will need the second output file from this
% run to get the full set of time metadata.
file2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';

time1 = ncread(file1, 'time');
time2 = ncread(file2, 'time');

% I like to work with times in a format known as 'datetime'. You can see
% the help section on datetime in the MATLAB documentation for details. I
% like datetimes because it is easy to work with calendar quantities like
% months, years, weeks, etc. These next few lines are me converting the
% output time (in days since 850, 1850) to the datetime format. The
% daynoleap2datenum accounts for the fact that models do not simulate leap
% days. The calmonths and caldays functions are me adjusting the date of
% each observation to the 15th of each month because that's how I like it.
%
% You do not need to provide metadata in datetime. You do not need to
% provide metadata in any specific format. Just use what you like. Dash is
% adaptive towards metadata and will accept whatever format you prefer. I
% just happen to like datetime, so that's what this tutorial uses.
time1 = daynoleap2datenum( time1, 850, 'dt') - calmonths(1) + caldays(14);
time2 = daynoleap2datenum( time2, 1850, 'dt') - calmonths(1) + caldays(14);
time = [time1; time2];

% We are almost ready to create the metadata structure for dash. But we
% still need to provide the size of the data and the order of the
% dimensions. LME output is provided in .nc files, and these quantities are
% easy to look at. We can use the ncdisp function and then look at the
% "Size" and "Dimensions" output fields.
ncdisp(file1, 'TREFHT');
ncdisp(file2, 'TREFHT');

% So, using ncdisp, we can see that the data size in the first file is 
% 144 x 96 x 12000, and that these sizes correspond to the lon, lat,
% and time dimensions respectively. The second file is 144 x 96 x 1872,
% the only difference is the time dimension because the second set of
% output is shorter. Since we will append this data along the time
% dimension, the final data size will be 144 x 96 x 13872.
gridSize = [144, 96, 13872];

% And, as stated, the grid dimensions are lon, lat, and time. For
% dash, it is important that the user knows the name of each dimension as
% recognized by dash. Currently, dash recognizes lon, lat, lev, time, and
% run as data dimensions. These are the only dimension names that can be
% used to build metadata, anything else will throw an error. 
%
% Note that you do not need to note all data dimensions, just the
% dimensions present in your data. So, for example, TREFHT does not have
% any level associated with it, because it is essentially a surface
% variable. Thus, I do not need to note it here.
%
% If you want to alter the list of dimension names, please read the
% advanced documentation.
gridDims = {'lon','lat','time'};

% Last of all, this is the temperature variable, so let's call it 'T'.
varName = 'T';

% Okay! Lets make the metadata structure. As stated earlier, you don't need
% to know anything about how the metadata structure is built. Just give it
% metadata and tell it which dimension the metadata is for.
meta = buildMetadata( gridSize, gridDims, varName, 'lat', lat, 'lon', lon, 'time', time, 'run', run );

% Just to recap, this function says, here is metadata for a gridded data of
% a particular size with a particular order of dimensions. The gridded
% data will have this particular name. I have metadata many dimensions. 
% Since metadata can be in any format, let me specify which dimension this
% metadata is for: 'lat' -- the next input will be latitude metadata
%                   lat -- The actual metadata
%                  'lon' -- The next input will be longitude metadata
%                   lon -- The actual metadata
%                   etc.

% One note: You can provide no metadata for a dimension and
% dash will infill the metadata with NaN. This is particularly useful for
% singleton dimensions. In this example, 'lev' is a singleton dimension
% because all temperature data are from the bottom level of the atmosphere.
% Thus, I have provided no metadata for it here.

%% New .grid file

% And now we have a metadata structure. We can now save the model output in
% a .grid file. Let's load the data. We're going to load the data from both
% files and concatenate them along the 4th (time) dimension.
T = cat(3, ncread(file1,'TREFHT'), ncread(file2,'TREFHT') );

% Before we save any data, let's make a quick note. Later in this tutorial
% we will use this data to do DA in the months from May to September in the 
% Northern Hemisphere. 
%
% If we wanted, we could remove the months Jan-March and Oct - Dec from the data
% right now and only save the May-Sept data. Indeed, we'd only be saving
% ~1/2 as much data, so converting to a .grid file would be about twice as
% fast. A similar idea holds for removing Southern Hemisphere data and
% saving it now.
%
% However, I would NOT recommend this. In a later study, I may
% want to examine April - November, or DJF, or the southern hemisphere. If
% I do not include all the data now, I would need to create another
% entire gridfile in the future, which would take a while. By including all
% model output now, I can reuse this .grid file any time I want to do data
% analysis on LME surface temperature. Even if the process takes longer 
% now, it will be MUCH MUCH faster than building multiple .grid files.
%
% An important point here is that dash does not usually use all the data in
% a .grid file to run a DA analysis. Later in this tutorial, we will see how
% to instruct dash to analyze ONLY the data we are interested in. The point of
% the .grid file is NOT to provide the data for a specific analysis.
% Rather, a .grid file is for storing all the information for a model
% variable in a MATLAB readable format so that we can use specific parts of
% that data later.

% Okay, back to the tutorial. We have our gridded dataset and metadata
% structure, let's create a .grid file. Let's call it Tref-LME.grid
gridName = 'Tref-LME.grid';

% Now, we make the file.
newGridfile( gridName, T, gridDims, meta );

% So to recap, this function says, Build a .grid file with a specific name.
% Here is the gridded data to save in the file. The gridded data is in this
% specific order of dimensions. It has this metadata associated with it.

%% Extend .grid file

% Great! We have a gridfile. This is all we need to begin running dash.
% But, we might want to add the other LME runs to the file. This would
% allow us to create larger ensembles for data analysis.
%
% My computer does not have enough storage to hold multiple LME runs in
% memory at the same time. So, instead of loading all the runs at once, I'm
% going to open each one sequentially and write it into the .grid file.
%
% Now, dash requires that each data element has metadata associated with
% it. Thus, when we add a new run, we will need to provide new metadata for
% that run. But we don't need to bother making an entire metadata structure.
% The structure for the metadata is already saved inside the .grid file,
% and we just want to provide some new values to write in it. So when we
% extend the gridfile down a particular dimension, we only need to give the
% metadata for the new run as the "meta" input.

% So, for each remaining run (run 1 was corrupted, and we just did run 2)
for r = 3:13
    
    % We're going to get the filename of the run
    file1 = sprintf('b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.TREFHT.085001-184912.nc', r);
    file2 = sprintf('b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.TREFHT.185001-200512.nc', r);
    
    % And read out the gridded T data.
    T = cat(3, ncread(file1,'TREFHT'), ncread(file2,'TREFHT') );
    
    % Now that we have the new data, we're going to write it into the .grid
    % file along with the new metadata
    extendGridfile(gridName, T, gridDims, 'run', [], r );
    
    % So, to recap. This function says, get the .grid file with this name,
    % and write this data into the file. The data is in this order of
    % dimensions. Append the new data to the run dimension. The metadata
    % value for this run is r (the index of the current run).
    %
    % For now, don't worry about the 5th input argument. It is used to
    % specify where to write the data if we want to extend a dimension but
    % also overwrite some old data. By leaving it empty, we are instructing
    % it to not overwrite any old data and just append everything to the
    % end of the 'run' dimension. If you are interested in this
    % functionality, please see the advanced documentation.
    %
    % Note that we needed to provide the names of the grid dimensions in
    % order to append to the file. This is because you can provide data to
    % dash in ANY dimensional ordering. You will never need to permute
    % gridded data. As long as you tell dash what order the data is in, it
    % will handle all permutations and mappings. So if the second file was
    % time x lev x lat x lon, we could provide it directly to
    % extendGridfile as long as we changed gridDims to
    % {'time','lev','lat','lon'}
end


%% Build a .grid file for P

% By now, we should have a file Tref-LME.grid that holds all the data for the
% first level of temperature data. As stated earlier, the ultimate goal is
% to run a DA of NTREND using VS-Lite. To run VS-Lite, we will need both T
% and P data, so we'll need to make a second .grid file for P.

% Just to emphasize again, the point of a .grid file is NOT to hold the
% data for a particular analysis. Rather, the point is to hold data in a
% common, MATLAB-readable format for ANY AND ALL future analyses. Thus, I
% do not recommend trying to add Precipitation data to Tref-LME.mat. This 
% would force future analyses to always consider both T and P. Rather, I
% STRONGLY RECOMMEND using .grid files to hold the full dataset for
% specific variables from a model run.

% We'll start by making a metadata structure. Now, P is calculated on the
% same grid (i.e. the surface) as TREFHT, so we can use the same
% metadata in the P metadata structure. However, we do need to note that
% this is a different variable and specify a different name.

% So let's build the metadata structure. Again, this says, build some
% metadata for gridded data with these dimensions. The dimensions of the
% grid are these. This variable will be named P. Here is metadata for lat,
% lon, time, and run.
metaP = buildMetadata( gridSize, gridDims, 'P', 'lat', lat, 'lon', lon, 'time', time, 'run', 2);

% Now let's make a P gridfile. In LME, precipitation is split into PRECC and
% PRECL. Note that I am not interested in either variable separately, but
% rather the full precipitation variable P = PRECC + PRECL. It's true that
% PRECC and PRECL are model variables, but P ~= PRECC and P ~= PRECL, it is
% its own variable. So I'm going to make a .grid file for P = PRECC + PRECL
% and not two .grid files for PRECC and PRECL separately. 

% So, for each LME run, I will need 4 files. Pre/post industrial for PRECC
% and pre/post industrial for PRECL
precc1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECC.085001-184912.nc';
precc2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECC.185001-200512.nc';

precl1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECL.085001-184912.nc';
precl2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.PRECL.185001-200512.nc';

% Load the pre/post industrial PRECC and PRECL files. Concatenate them 
% along the time dimension (dimension 3). Add PRECC and PRECL to get the
% full precipitation variable.
P = cat(3, ncread(precc1, 'PRECC'), ncread(precc2,'PRECC')) + cat(3, ncread(precl1, 'PRECL'), ncread(precl2, 'PRECL'));

% Create the .grid file to hold a P variable.
Pgrid = 'P-LME.grid';
newGridfile(Pgrid, P, gridDims, metaP);

% Now add the other runs
for r = 3:13

    % Get the files
    precc1 = sprintf( 'b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.PRECC.085001-184912.nc', r);
    precc2 = sprintf( 'b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.PRECC.185001-200512.nc', r);

    precl1 = sprintf( 'b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.PRECL.085001-184912.nc', r);
    precl2 = sprintf( 'b.e11.BLMTRC5CN.f19_g16.0%02.f.cam.h0.PRECL.185001-200512.nc', r);

    % Get the precipitation variable
    P = cat(3, ncread(precc1, 'PRECC'), ncread(precc2,'PRECC')) + cat(3, ncread(precl1, 'PRECL'), ncread(precl2, 'PRECL'));
    
    % Write to the .grid file and append to the 'run' dimension. Add a new
    % metadata value for the new run.
    extendGridfile( Pgrid, P, gridDims, 'run', [], r );
end

%% Recap

% Alright, we should now have two files P-LME.grid and Tref-LME.grid that hold
% all the TREFHT and P data from the 12 LME runs.
%
% This probably took a while. It is likely to be the slowest step of any
% analysis. This is why we went ahead and provided ALL the data for the
% variables now. These .grid files are complete and we will never have to
% build them again. We can use them for any application that needs T and P
% from LME for dash without rebuilding or recompiling data.