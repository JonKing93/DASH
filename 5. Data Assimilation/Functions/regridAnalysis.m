function[rA, meta, dimID] = regridAnalysis( A, var, ensMeta, design, varargin )
%% Regrids a variable from a particular time step for a DA analysis.
%
% [rA, meta, dimID] = regridAnalysis( A, var, ensMeta, design )
% Regrids a variable from output. Removes any singleton dimensions.
%
% [rA, meta, dimID] = regridAnalysis( A, var, ensMeta, design, 'nosqueeze' )
% Preserves all singleton dimensions.
%
% ----- Inputs -----
%
% A: A state vector. Typically, the updated ensemble mean or variance (nState x 1).
%
% var: The name of a variable. Must be a string.
%
% ensMeta: The ensemble metadata
%
% design: A state vector design.
%
% ----- Outputs -----
%
% rA: A regridded analysis for one variable.
%
% meta: Metadata associated with each element of the regridded data.
%
% dimID: The order of the dimensions for the regridded variable.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check for nosqueeze
nosqueeze = parseInputs( varargin, {'nosqueeze'}, {false}, {'b'} );

% Get the indices of the variable in the state vector
varDex = getVarStateIndex(ensMeta, var);

% Also get the variable in the state vector design
v = checkDesignVar(design, var);
var = design.var(v);

% Preallocate the grid size and metadata
nDim = numel(var.dimID);
gridSize = ones(1, nDim+1);
meta = struct();

% For each grid dimension
for d = 1:nDim
    
    %  Get the name of the dimension
    dim = var.dimID(d);
    
    % If a state dimension
    if var.isState(d)
        
        % Get the metadata
        meta.(dim) = var.meta.(dim)( var.indices{d}, : );
        
        % Get the size if not a mean
        if ~var.takeMean(d)
            gridSize(d) = numel( var.indices{d} );
        end
        
    % Otherwise, if an ensemble dimension
    else
        
        % Get the metadata
        meta.(dim) = var.seqMeta{d};
        
        % Get the size
        gridSize(d) = numel( var.seqDex{d} );
    end
end

% Last dimension is DA time steps
nTime = size(A, 2);
gridSize(d+1) = nTime;

% Regrid the variable in A
rA = reshape( A(varDex,:), gridSize );

% Get the dimension ordering
dimID = [var.dimID; "DA_Time_Steps"];

% Add in metadata for the DA time steps
meta.(dimID(end)) = (1:gridSize(end))';

% If reducing dimensions
if ~nosqueeze
    
    % Get the singular dimensions
    singDim = size(rA)==1;
    
    % Remove their metadata
    meta = rmfield( meta, dimID(singDim) );
    
    % Remove their dimIDs
    dimID(singDim) = [];
    
    % Reduce the dataset
    rA = squeeze(rA);
end
    
end