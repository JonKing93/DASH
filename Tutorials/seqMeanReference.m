%% Sequence and mean refererence guide

% Assume we have a file with some monthly sst data. The data has some
% associated ocean grids, and a certain number of time points.
% (These are just mock values, substitute your own data here.) 
file = 'myFile.grid';   
ocean = myOceanGrids;
nTime = totalTimePoints;


%% Build an 20 year annual mean state vector
%
% So this state vector looks like:     [
%                                       Ann - 20 years
%                                      ]

% Initialize a design
design = stateDesign('Annual, 20 year bins');

% Add the sst variable
design = addVariable( design, file, 'sst' );

% Two options:
%    1. Set the 20 year bins so that the maximum ensemble size is possible.
%       This requires only pointing to one year out of 20.
%
%    2. Start bins from any year. The ensemble size might be a bit smaller,
%       but the workflow is more simple.

% Option 1:
binSize = 12 * 20;
ensIndex = 1:binSize:nTime;
meanIndex = 0:binSize-1;

design = editDesign( design, 'sst', 'tri', 'index', ocean );
design = editDesign( design, 'sst', 'run', 'ens' );
design = editDesign( design, 'sst', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );

% Option 2:
binSize = 12 * 20;
ensIndex = 1:12:nTime;
meanIndex = 0:binSize-1;

design = editDesign( design, 'sst', 'tri', 'index', ocean );
design = editDesign( design, 'sst', 'run', 'ens' );
design = editDesign( design, 'sst', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );


%% Build a state vector that is the 20 year mean of just JJA
%
% State vector:  [
%                 JJA - 20 years
%                ]

% I'm going to stick with Option 1 (from the preceding section) for the
% remainder of this guide. But to switch to option 2, change ensIndex to
% >> ensIndex = 1:12:nTime

binSize = 12 * 20;
ensIndex = 1:binSize:nTime;
meanIndex = [ 5:12:binSize-1, 6:12:binSize-1, 7:12:binSize-1 ];
% Note that june starts at 5 because the ensemble index points to january,
% and the mean indices are 0 indexed.

design = stateDesign('JJA, 20 year bins');
design = addVariable( design, file, 'sst' );

design = editDesign( design, 'sst', 'tri', 'index', ocean );
design = editDesign( design, 'sst', 'run', 'ens' );
design = editDesign( design, 'sst', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );



% Alternatively, this code produces an identical result
binSize = 12 * 20;
ensIndex = 6:binSize:nTime;
meanIndex = [ 0:12:binSize-1, 1:12:binSize-1, 2:12:binSize-1 ];

design = editDesign( design, 'sst', 'tri', 'index', ocean );
design = editDesign( design, 'sst', 'run', 'ens' );
design = editDesign( design, 'sst', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );

% Here the ensemble index says to start drawing information from June, and
% then take the mean over the appropriate months.


%% Build a state vector that is the 20 year mean of J, J, and A separately.
%
% State vector:   [
%                   J - 20 years
%                   J - 20 years
%                   A - 20 years
%                  ]

binSize = 12 * 20;
ensIndex = 1:binSize:nTime;

seqIndex = [5 6 7];   % This is pointing at J, J, and A discretely.
ensMeta = ["June";"July";"August"];   % Metadata is required for sequences.

meanIndex = 0:12:binSize-1;  % Take the mean of each specific month (which is 0
                             % indexed from the sequence index), over 20 years.

design = stateDesign('J, J, A (monthly) 20 year bins');
design = addVariable( design, file, 'sst' );
                      
design = editDesign( design, 'sst', 'tri', 'index', ocean );
design = editDesign( design, 'sst', 'run', 'ens' );
design = editDesign( design, 'sst', 'time', 'ens', 'index', ensIndex, ...
                     'meanIndex', meanIndex, 'meta', ensMeta );

                      

%% Build a state vector that is a 20 year mean of annual, JJA, ASO, and DJFM
%
% State vector: [
%                Annual - 20 years
%                JJA - 20 years
%                ASO - 20 years
%                DJFM - 20 years
%               ]
%
% In this state vector, each of the sets of months has a different set of
% mean indices. Thus, we will need to create a new variable for each set of
% months.

design = stateDesign('For UK37 polygons');

binSize = 12 * 20;

% Annual
ensIndex = 1:binSize:nTime;
meanIndex = 0:binSize-1;

design = addVariable( design, file, 'sst-ann' );
design = editDesign( design, 'sst-ann', 'tri', 'index', ocean );
design = editDesign( design, 'sst-ann', 'run', 'ens' );
design = editDesign( design, 'sst-ann', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );

% JJA
ensIndex = 1:binSize:nTime;
meanIndex = [ 5:12:binSize-1, 6:12:binSize-1, 7:12:binSize-1 ];

design = addVariable( design, file, 'sst-jja' );
design = editDesign( design, 'sst-jja', 'tri', 'index', ocean );
design = editDesign( design, 'sst-jja', 'run', 'ens' );
design = editDesign( design, 'sst-jja', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );

% ASO
ensIndex = 1:binSize:nTime;
meanIndex = [ 7:12:binSize-1, 8:12:binSize-1, 9:12:binSize-1 ];

design = addVariable( design, file, 'sst-aso' );
design = editDesign( design, 'sst-aso', 'tri', 'index', ocean );
design = editDesign( design, 'sst-aso', 'run', 'ens' );
design = editDesign( design, 'sst-aso', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );

% DJFM
ensIndex = 1:binSize:nTime;
meanIndex = [ 11:12:binSize-1-12, 12:12:binSize-1, 13:12:binSize-1, 14:12:binSize-1 ];
% Note that we removed an extra year from the mean index for December so
% that it doesn't read 1 extra december into the bin.

design = addVariable( design, file, 'sst-djfm' );
design = editDesign( design, 'sst-djfm', 'tri', 'index', ocean );
design = editDesign( design, 'sst-djfm', 'run', 'ens' );
design = editDesign( design, 'sst-djfm', 'time', 'ens', 'index', ensIndex, 'meanIndex', meanIndex );


% These could be used with a polygonal ukPSM using code similar to the
% following:
for s = 1:nSite
    F{s} = ukPSM( ukLat(s), ukLon(s) );
    
    if isInPolygonA
        varName = 'sst-ann';
    elseif isInPolygonB
        varName = 'sst-jja';
    elseif isInPolygonC
        varName = 'sst-aso';
    else
        varName = 'sst-djfm';
    end
    
    F{s}.getStateIndices( ensMeta, varName );
end