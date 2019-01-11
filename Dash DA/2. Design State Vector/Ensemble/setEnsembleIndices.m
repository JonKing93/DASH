function[var] = setEnsembleIndices( var, dim, index, seq, mean, nanflag )
%% Actually sets the ensemble indices for a variable

% Get the dimension index
d = checkVarDim(var, dim);

% Error check the indices
checkIndices(var, d, index);
checkIndices(seq+1, d, index);
checkIndices(mean+1, d, index);

% Error check the nanflag
if ~ischar(nanflag) || ~isvector(nanflag) || ~ismember(nanflag, {'omitnan','includenan'})
    error('nanflag must be either ''omitnan'' or ''includenan''.');
% Check that mean and sequence include the 0 index
elseif ~ismember(0,seq) || ~ismember(0,mean)
    error('Sequence and mean indices must contain the 0 index.');
end

% Get the value of takeMean
takeMean = true;
if isequal(mean,0)
    takeMean = false;
end

% Check that there are no partial sequences
if any( trimEnsemble(var,dim,index,seq,mean) )
    error('Not all ensemble indices permit a full sequence.');
end

% Set the values
var.indices{d} = index;
var.seqDex{d} = seq;
var.meanDex{d} = mean;
var.takeMean(d) = takeMean;
var.nanflag{d} = nanflag;

end