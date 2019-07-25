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
    meta = var1.meta.(ensID(dim))( var1.indices{d}, : );
    
    % Go through the remaining variables
    for v = 2:numel(cv)
        varCurr = design.var( cv(v) );
        
        % Get the index of the dimension in the variable
        d = checkVarDim( varCurr, ensID(dim) );
        
        % Get the metadata for the current variable
        currMeta = varCurr.meta.(ensID(dim))( varCurr.indices{d}, : );
        
        % Get the intersect of the two metadata sets
        meta = intersect( meta, currMeta, 'rows', 'stable' );        
    end
    
    % Throw an error if no metadata remains
    if isempty(meta)
        overlapError(design, cv, ensID(dim));
    end

    % Then run through each coupled variable
    for v = 1:numel(cv)
        
        % Get the index of each ensemble dimension
        varCurr = design.var( cv(v) );
        d = checkVarDim( varCurr, ensID(dim) );
        
        % Get the metadata for the variable
        currMeta = varCurr.meta.(ensID(dim))( varCurr.indices{d}, : );

        % And restrict indices so they match the final set of intersecting metadata
        [~, iB] = intersect( meta, currMeta, 'rows', 'stable' );
        design.var( cv(v) ).indices{d} = varCurr.indices{d}(iB);
    end
end

end

function[] = overlapError(design, cv, dim)

coupled = sprintf('%s, ', design.var(cv).name);
error( ['The ensemble indices of the %s dimension of coupled variables: %s', ...
        'have no overlapping metadata.', newline, ...
        'Check that the ensemble indices point to the same values, and that the .grid metadata is in a common format.'], ...
        dim, coupled );
end