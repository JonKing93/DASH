function[seq, mean, nanflag] = getSyncedProperties( var, template, dim, syncSeq, syncMean )
% Returns sequence, mean, and nanflag values for a variable after checking
% whether it is coupled to a changed variable.
%
% [seq, mean, nanflag] = getSyncedProperties( var, template, dim, syncSeq, syncMean )
%
% ----- Inputs -----
%
% var: The name of the variable.
%
% template: The name of the altered variable that var may be coupled with.
%
% dim: The dimension being altered.
%
% syncSeq: A logical indicating whether sequence indices are synced.

% Get the dimension index in each variable
xd = checkVarDim(template,dim);
yd = checkVarDim(var,dim);

% Set the defaults
seq = var.seqDex{yd};
mean = var.meanDex{yd};
nanflag = var.nanflag{yd};

% If syncing sequences
if syncSeq
    seq = template.seqDex{xd};
end

% If syncing means
if syncMean
    mean = template.meanDex{xd};
    nanflag = template.nanflag{xd};
end

end
