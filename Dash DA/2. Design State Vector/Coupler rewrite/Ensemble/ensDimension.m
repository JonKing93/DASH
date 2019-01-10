function[] = ensDimension( design, var, dim, index, seq, mean, nanflag )

%%%%% Defaults
if ~exist('seq','var') || isempty(seq)
    seq = 0;
end
if ~exist('mean','var') || isempty(mean)
    mean = 0;
end
if ~exist('nanflag','var')
    nanflag = 'includenan';
end
%%%%%

% Get the variable design
v = checkDesignVar(design, var);
var = design.varDesign(v);

% Get the dimension index
d = checkVarDim(var, dim);

% Check that the indices are allowed and trim to only allow full sequences
checkIndices(var, d, index)

trimDex = trimEnsemble(var, d, index, seq, mean);
index = index(~trimDex);

% Get the metadata for the dimension
meta = metaGridfile( var.file );
meta = meta.(var.dimID{d});

% Get the variables with coupled ensemble indices
coupled = find( design.isCoupled(v,:) );
coupVars = design.varDesign(coupled);

% Preallocate an index array to track overlapping metadata
nCoup = sum(coupled);
ensDex = NaN(numel(index),nCoup+1);
ensDex(:,1) = index;

% Get the ensemble indices for each variable. Trim and propagate through
% the ensemble indices of all coupled variables.
for c = 1:nCoup
    
    % Get the index of the dimension
    d = checkVarDim(coupVars(c), dim);
    
    % Get the indices with matching metadata
    [iy, ix] = getCoupledEnsIndex( coupVars(c), dim, meta(ensDex(:,1)) );
    
    % Set the values in the index array
    ensDex(ix,c+1) = iy;
    
    % Get the associated sequence indices
    currSeq = coupVars(c).seqDex{d};
    if design.coupleSeq(v, coupled(c))
        currSeq = seq;
    end
    
    % Get the associated mean indices
    currMean = coupVars(c).meanDex{d};
    if design.coupleMean(v, coupled(c))
        currMean = mean;
    end
    
    % Trim the indices to only allow full sequences
    trimDex = trimEnsemble( coupVars(c), dim, iy, currSeq, currMean );
    
    % Trim the index array
    ensDex(ix(trimDex),:) = [];
    
    % Remove any non-overlapping values 
    ensDex( isnan(ensDex(:,c+1)), : ) = [];
end

% Check that ensDex is not empty
if isempty(ensDex)
    error('There are no ensemble members that permit full sequences of all coupled variables.');
end

% If no errors have been thrown, set the values
for c = 1:nCoup
    
    % Get the dimension index
    d = checkVarDim(coupVars(c), dim);
    
    % Set the ensemble indices
    coupVars(c).indices{d} = ensDex(:,c+1);
    
    % Sequence indices if coupled
    if design.coupleSeq(v, coupled(c))
        coupVars(c).seqDex{d} = seq;
    end
    
    % Mean indices if coupled
    if design.coupleMean(v, coupled(c))
        coupVars(c).meanDex{d} = mean;
        coupVars(c).nanflag{d} = nanflag;
    end
end

end
           
    
