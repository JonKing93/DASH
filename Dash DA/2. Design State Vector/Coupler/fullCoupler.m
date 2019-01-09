%% Couples two variables


% Get the variable designs
[~,xv] = ismember( X, design.var );
X = design.varDesign(xv);

[~,yv] = ismember( Y, design.var );
Y = design.varDesign(yv);

% Get the metadata for X and Y
xmeta = metaGridfile(X.file);
ymeta = metaGridfile(Y.file);

% For each dimension of X
for xd = 1:numel(X.dimID)
    
    % Get the corresponding dimension in Y
    [~,yd] = ismember( X.dimID{x}, Y.dimID );
    
    % Ensure the dimension actually is in y
    if isempty(yd)
        error('Y does not contain the %s dimension.', X.dimID{xd} );
    end
    
    % Get the metadata for X in the current dimenson at the indices. Get
    % the full set of dimensional metadata for Y
    currX = xmeta.( X.dimID{xd} )( X.indices{d} );
    currY = ymeta.( Y.dimID{yd} );
    
    % Note if sequence indices are coupled. If yes, set the indices to the
    % values in X.
    % !!!!! Probably need to move coupleSeq out of the for loop. Either all
    % or none.
    coupleSeq = false;
    if isempty(seqDex{xd})
        seqDex{xd} = X.seqDex{xd};
        coupleSeq = true;
    end
    
    % Note if mean indices are coupled. If yes, set the indices to the
    % values in X
    coupleMean = false;
    if isempty( meanDex{xd} )
        meanDex{xd} = X.meanDex{xd};
        coupleMean = true;
        
        takeMean(xd) = X.takeMean(xd);
        nanflag{xd} = X.nanflag{xd};
    end
    
    % Trim the Y indices to only allow full sequences and means
    iy = Y.trimEnsemble( 1:numel(currY), seqDex{xd}, meanDex{xd}, yd );
    
    % Ensure that none of the metadata is repeated
    if numel(unique(currX)) ~= numel(currX)
        error('The metadata for X in the %s dimension contains repeat values.', X.dimID{xd} );
    elseif numel(unique(currY)) ~= numel(currY)
        error('The metadata for Y in the %s dimension contain repeat values.', Y.dimID{yd} );
 
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
       
    % For state dimensions
    if X.isState(xd)
        
        % Check that every X index has a matching y index
        if numel(ix) ~= numel(currX)
            error('Y does not have metadata matching all the values in X at the state indices in the %s dimension.', X.dimID{xd});
        end
        
        % Add the state dimension to Y
        Y.stateDim( X.dimID{xd}, iy, X.takeMean(d), X.nanflag{d} );
        
    % For ensemble dimensions
    else
        
        % Add the new indices to both X and Y
        % !!!!! Need to fix meta so that it is speified if a different
        % sequence is used. Or different mean.
        Y.ensembleDim( X.dimID{xd}, META, iy, seqDex{xd}, meanDex{xd}, takeMean(d), nanflag{d} );
        X.index{xd} = ix;
    end 
end

% Record which indices are coupled.
design.isCoupled(xv,yv) = true;
design.isCoupled(yv,xv) = true;

design.coupleState(xv,yv) = coupleState;
design.coupleState(yv,xv) = coupleState;

design.coupleSeq(xv,yv) = coupleSeq;
design.coupleSeq(yv,xv) = coupleSeq;

design.coupleMean(xv,yv) = coupleMean;
design.coupleMean(yv,xv) = coupleMean;


    
    
    
    
    