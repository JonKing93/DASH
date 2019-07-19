function[meta] = initializeMeta( design, nState )
%% Builds an empty metadata container.
%
% design: stateDesign
%
% nState: Size of the state vector
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Initialize structure
meta = struct();

% Get field names for variable names and dimensions.
[dimID, ~, varID] = getDimIDs;

% Record variable names
meta.(varID) = design.varName;

% Initialize a field for each dimension
for d = 1:numel(dimID)
    meta.var(1,1).(dimID(d)) = [];
end

% Replicate over the total set of variables
nVar = numel( design.varName );
meta.var(2:nVar,1) = meta.var(1);

% Preallocate variable index limits
meta.varLim = NaN( nVar, 2 );

end