function[var] = setStateIndices( var, dim, index, takeMean, nanflag )
%% Actually sets the state indices for a variable.

% Get the dimension index
d = checkVarDim(var, dim);

% Error check the indices
checkIndices( var, d, index );

% Error check the mean and nanflag
if ~islogical(takeMean) || ~isscalar(takeMean)
    error('takeMean for variable %s is not a logical scalar.', var.name);
elseif ~ischar(nanflag) || ~isvector(nanflag) || ~ismember(nanflag, {'omitnan','includenan'})
    error('nanflag for variable %s is neither ''omitnan'' nor ''includenan''.', var.name);
end
    
% Set the values
var.indices{d} = index;
var.takeMean(d) = takeMean;
var.nanflag{d} = nanflag;

% Set the dimension as a state dimension
var.isState(d) = true;
var.dimSet(d) = true;

end