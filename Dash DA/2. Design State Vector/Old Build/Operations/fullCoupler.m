function[design] = fullCoupler( design, X, Y, varargin )

% coupleVariables( design, X, Y )
% Couples the ensemble indices of X and Y. Syncs the state, sequence, and
% mean indices of Y to X.
%
% coupleVariables( ..., 'nostate')
% Does not sync state indices.
%
% coupleVariables( ..., 'noseq' )
% Does not sync sequence indices.
%
% coupleVariables( ..., 'nomean' )
% Does not sync mean indices.

% Parse the inputs
[nostate, noseq, nomean] = parseInputs( varargin, {'nostate','noseq','nomean'}, {false, false, false}, {'b','b','b'} );

% Error check
% !!!

% Get the variable designs
[~,xv] = ismember( X, design.var );
X = design.varDesign(xv);

[~,yv] = ismember( Y, design.var );
Y = design.varDesign(yv);

% Get the metadata for X and Y
xmeta = metaGridfile(X.file);
ymeta = metaGridfile(Y.file);

% Preallocate varDesign properties
nXDim = numel( X.dimID );
seqDex = cell(nXDim,1);
meanDex = cell(nXDim,1);
takeMean = false(nXDim,1);
nanflag = cell(nXDim,1);

% For each dimension of X that should be synced
for xd = 1:numel(X.dimID)
        
        % Get the corresponding dimension in Y
        [~,yd] = ismember( X.dimID{xd}, Y.dimID );
        if isempty(yd)
            error('Y does not contain the %s dimension.', X.dimID{xd} );
        end
    
        % Get the metadata for X in the current dimenson at the indices. Get
        % the full set of dimensional metadata for Y
        currX = xmeta.( X.dimID{xd} )( X.indices{d} );
        currY = ymeta.( Y.dimID{yd} );
    
        % Set sequence indices for ensemble dimensions.
        if ~X.isState(xd) && ~noseq
            seqDex{xd} = X.seqDex{xd};
        elseif ~X.isState(xd)
            seqDex{xd} = 0;
        end
    
        % Sync mean indices and associated mean properties for ensemble
        % dimensions.
        if ~X.isState(xd) && ~nomean
            meanDex{xd} = X.meanDex{xd};
            takeMean(xd) = X.takeMean(xd);
            nanflag{xd} = X.nanflag{xd};
        elseif ~X.isState(xd)
            meanDex{xd} = 0;
            takeMean(xd) = false;
            nanflag{xd} = 'includenan';
        end
        
        % Initialize an index for metadata comparison
        iy = 1:numel(currY);
        
        % Trim the comparison in ensemble dimensions to full sequences
        if ~X.isState(xd)
            iy = Y.trimEnsemble( iy, seqDex{xd}, meanDex{xd} );
        end
    
        % Ensure that none of the metadata is repeated
        if numel(unique(currX)) ~= numel(currX)
            error('The metadata for X in the %s dimension contains repeat values.', X.dimID{xd} );
        elseif numel(unique(currY)) ~= numel(currY)
            error('The metadata for Y in the %s dimension contains repeat values.', Y.dimID{yd} );
 
        % NaN metadata is only permissible if the dimension is a singleton for
        % both variables. If this is the case, and the metadata match, the
        % singleton index is the index.
        elseif numel(xmeta.(X.dimID{xd}))==1 && numel(ymeta.(Y.dimID{yd}))==1 && ...
                isequaln(currX, currY)
            ix = 1;
            iy = 1;

        % Otherwise, get the intersecting indices
        else
            [~, ix, iy] = intersect( currX, currY(iy) );

            % Throw error if there are no intersecting indices
            if isempty(ix)
                error('The two variable have no intersecting metadata that permit full sequences.');
            end

        end
       
    % If syncing state dimensions
    if X.isState(xd) && ~nostate       
        
        % Check that every X index has a matching y index
        if numel(ix) ~= numel(currX)
            error('Y does not have metadata matching all the values in X at the state indices in the %s dimension.', X.dimID{xd});
        end
        
        % Add the state dimension to Y
        Y.stateDim( X.dimID{xd}, iy, X.takeMean(d), X.nanflag{d} );
        
    % For ensemble dimensions
    elseif ~X.isState(xd)
        
        % Add the new indices to both X and Y
        % !!!!! Need to fix meta so that it is speified if a different
        % sequence is used. Or different mean.
        Y.ensembleDim( X.dimID{xd}, META, iy, seqDex{xd}, meanDex{xd}, takeMean(d), nanflag{d} );
        X.index{xd} = ix;
    end 
end
