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

% Include the variable name as a metadata field
metaField = ["var", dimID];

% Create a cell of input arguments to create the metadata structure
sArgs = cell( numel(metaField)*2, 1 );

% Add the name and (empty) values for each field
for f = 1:numel(metaField)
    sArgs{f*2-1} = metaField(f);    % Name
    
    % Place values in a cell so that the struct is not recast as an array
    sArgs{f*2} = { cell(nState, 1) };
end

% Use empty strings for the variable name
sArgs{2} = repmat( "", [nState, 1]);

% Create the empty structure
meta = struct( sArgs{:} );

end