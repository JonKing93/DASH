function[seq, mean, nanflag] = getSyncedProperties( X, Y, dim, syncSeq, syncMean )

% Get the dimension index in each variable
xd = checkVarDim(X,dim);
yd = checkVarDim(Y,dim);

% Set the defaults
seq = Y.seqDex{yd};
mean = Y.meanDex{yd};
nanflag = Y.nanflag{yd};

% If syncing sequences
if syncSeq
    seq = X.seqDex{xd};
end

% If syncing means
if syncMean
    mean = X.meanDex{xd};
    nanflag = X.nanflag{d};
end

end
