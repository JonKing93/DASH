function[var] = setEnsembleIndices( var, dim, index, seq, mean, nanflag, meta )
%% Actually sets the ensemble indices for a variable

% Get the dimension index
d = checkVarDim(var, dim);

% Error check the indices
checkIndices(var, d, index);
checkIndices(var, d, seq+1);
checkIndices(var, d, mean+1);

% Error check the nanflag
if ~ischar(nanflag) || ~isvector(nanflag) || ~ismember(nanflag, {'omitnan','includenan'})
    error('nanflag for variable %s is neither ''omitnan'' nor ''includenan''.', var.name);
% Check that mean indices include the 0 index
elseif ~ismember(0,mean)
    error('Mean indices for variable %s must contain the 0 index.', var.name );
end

% Get the value of takeMean
takeMean = true;
if isequal(mean,0)
    takeMean = false;
end

% Check that there are no partial sequences
if any( trimEnsemble(var,dim,index,seq,mean) )
    error('Not all ensemble indices in the %s dimension of the %s variable permit a full sequence.', dim, var.name);
end

% Convert index to column, seq and mean to row
if ~iscolumn(index)
    index = index';
end
if ~isrow(seq)
    seq = seq';
end
if ~isrow(mean)
    mean = mean';
end

% Set the values
var.indices{d} = index;
var.seqDex{d} = seq;
var.meanDex{d} = mean;
var.takeMean(d) = takeMean;
var.nanflag{d} = nanflag;
var.ensMeta{d} = meta;

% Set the dimension as an ensemble dimension
var.isState(d) = false;
var.dimSet(d) = true;

end