function[meta] = initializeMeta( design, nState )
%% Builds an empty metadata container
%
% design: stateDesign
%
% nState: Size of the state vector
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the collection of all unique dimensions
dimID = {};
for v = 1:numel(design.var)
    
    % Get the dimensions in the variable
    currDim = design.var(v).dimID;
    
    % Add any new dimensions to the set of dimIDs
    dimID = unique( [dimID, currDim] );
end

% Add the variable name as metadata
dimID = ['var', dimID];

% Create an input cell for the metadata structure
inArgs = cell(numel(dimID)*2,1);
inArgs(1:2:end) = dimID;

% Create the structure (Not going to add the empty metadata because would
% switch from scalar structure to structure array)
meta = struct( inArgs{:} );

% Create the empty metadata placeholder
emptyMeta = cell( nState,1 );

% Now add the empty metadata
for d = 2:numel(dimID)
    meta.(dimID{d}) = emptyMeta;
end

% Get the empty variable name placeholder
meta.(dimID{1}) = repmat( "", [nState,1]);

end