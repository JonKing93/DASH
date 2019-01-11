function[var] = setStateIndices( var, dim, index, takeMean, nanflag )
%% Actually sets the state indices for a variable.

% Get the dimension index
d = checkVarDim(var, dim);

% Error check the indices
checkIndices( var, d, index );

% Error check the mean and nanflag
if ~islogical(takeMean) || ~isscalar(takeMean)
    error('takeMean must be a logical scalar.');
elseif ~ischar(nanflag) || ~isvector(nanflag) || ~ismember(nanflag, {'omitnan','includenan'})
    error('nanflag must be either ''omitnan'' or ''includenan''.');
end
    
% Set the values
var.indices{d} = index;
var.takeMean(d) = takeMean;
var.nanflag{d} = nanflag;

end