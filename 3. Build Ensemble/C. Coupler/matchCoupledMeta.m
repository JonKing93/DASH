function[design] = matchCoupledMeta( design, cv )
%% Gets the most restrictive metadata for a set of coupled variables.
%
% design: stateDesign
%
% cv: Variable indices of coupled variables
%
% ensDim: Name of ensemble dimensions
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the first variable for quick reference
var1 = design.var( cv(1) );

% Get the ensemble dimension IDs
ensID = var1.dimID( ~var1.isState );

% For each ensemble dimension
for dim = 1:numel(ensID)
    
    % Initialize the metadata with the values from the first variable
    d = checkVarDim( var1, ensID(dim) );
    meta = var1.meta.(ensID(dim))( var1.indices{d} );
    
    % Go through the remaining variables
    for v = 2:numel(cv)
        varC = design.var( cv(v) );
        
        % Get the index of the dimension in the variable
        d = checkVarDim( varC, ensID(dim) );
        
        % Get the metadata for the current variable
        currMeta = varC.meta.(ensID(dim))( varC.indices{d} );
        
        % Get the intersect of the two metadata sets
        match = matchingMetaIndex( meta, currMeta );
        meta = indexMetadata(meta, match);        
    end
    
    % Throw an error if no metadata remains
    if isempty(meta)
        overlapError(design, cv, dim);
    end

    % Then run through each coupled variable
    for v = 1:numel(cv)
        
        % Get the index of each ensemble dimension
        varC = design.var( cv(v) );
        d = checkVarDim( varC, ensID(dim) );
        
        % Get the metadata for the variable
        currMeta = varC.meta.(ensID(dim))( varC.indices{d} );

        % And restrict indices so they match the final set of intersecting metadata
        [~, iB] = matchingMetaIndex( meta, currMeta );
        design.var( cv(v) ).indices{d} = varC.indices{d}(iB);
    end
end

end

function[] = overlapError(design, cv, dim)

coupled = sprintf('%s, ', design.var(cv).name);
error( ['There is no overlapping metadata for the %s dimension of coupled variables: %s', ...
        'so they cannot be coupled.', newline, ...
        'Use the functions "metaGridfile.m" and "rewriteGridMetadata.m" to ensure that metadata is in a common format.'], ...
        dim, coupled );
end