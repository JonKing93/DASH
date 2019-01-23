function[design] = stateDimension( design, var, dim, index, takeMean, nanflag )
%% Edits a state dimension.

% Parse the inputs
[index, takeMean, nanflag] = parseInputs( varargin, {'index','mean','nanflag'}, {[],[],[]}, {[],[],{'omitnan','includenan'}} );

% Get the variable index
v = checkDesignVar( design, var );

% Get the dimension index
d = checkVarDim( var, dim );

%% Get the values to use

% Get the indices to use
if isempty(index)
    index = design.var(v).indices{d};
elseif strcmpi(index, 'all')
    index = 1:design.var(v).dimSize(d);
end

% Get the value of takeMean
if isempty(takeMean)
    takeMean = design.var(v).takeMean(d);
end
if ~islogical(takeMean) || ~isscalar(takeMean)
    error('takeMean must be a logical scalar.');
end

% Get the nanflag
if isempty(nanflag)
    nanflag = design.var(v).nanflag{d};
end


%% Sync / Couple

% Get any synced variables
sv = find( design.isSynced(v,:) );

% Get any variables that are just coupled, not synced
cv = find( design.isCoupled(v,:) );
cv = cv( ~ismember(cv, sv) );

% Get the set of all associated variables
av = [sv;cv];
nVar = numel(av);

% Notify user if changing from ens to state dimension
if ~design.var(v).isState(d)
    flipDimWarning(dim, var, {'ensemble','state'}, design.varName(av));
end

% For each associated variable
for k = 1:nVar
    
    % Get the dimension index for the associated variable
    ad = checkVarDim( design.var(av(k)), dim );
    
    % Change dimension to state dimension
    design.var(av(k)).isState(ad) = true;
    
    % If a synced variable
    if ismember(av(k),sv)
        
        % Get the matching indices
        design.var(av(k)).indices{ad} = getMatchingMetaDex( design.var(av(k)), ...
                                         dim, design.var(v).meta.(dim), true );
                                     
        % Set the mean and nanflag values
        design.var(av(k)).nanflag{ad} = nanflag;
        design.var(av(k)).takeMean(ad) = takeMean;
    end
end

end