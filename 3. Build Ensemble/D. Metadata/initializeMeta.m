function[meta] = initializeMeta( design, nState )
%% Builds an empty metadata container.
%
% design: stateDesign
%
% nState: Size of the state vector
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the collection of all unique dimensions
dimID = [];
for v = 1:numel(design.var)
    currDim = design.var(v).dimID;
    dimID = unique( [dimID, currDim] );
end

% Initialize the metadata structure
meta = struct();

% Add the variable name
[~,~,varName] = getDimIDs;
meta.(varName) = repmat( "", [nState,1] );

% Initialize the grid fields with empty cells
for d = 1:numel(dimID)
    meta.(dimID(d)) = cell(nState,1);
end

end