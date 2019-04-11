function[] = checkVarValues( var )

% Check that there is at least one state dimension and at least one
% ensemble dimension
if ~any( var.isState )
    error('Variable %s does not have any state dimensions.', var.name );
elseif ~any( ~var.isState )
    error('Variable %s does not have any ensemble dimensions.', var.name);
end

% For each dimension
for d = 1:numel(var.dimID)
    
    % Check if the indices are allowed
    checkIndices(var, d, var.indices{d});
    
    % Check that the nanflag is recognized
    if ~ismember(var.nanflag{d}, ["includenan","omitnan"])
        error('The nanflag for the %s dimension of variable %s is an unrecognized value.', var.dimID(d), var.name);
    end
    
    % If a state dimension
    if var.isState(d)
        
        % Check that the mean indices are empty
        if ~isempty(var.meanDex{d})
            error('The %s dimension of variable %s has mean indices, but it is a state dimension.', var.dimID(d), var.name );
        
        % And that sequence indices are empty
        elseif ~isempty(var.seqDex{d})
            error('The %s dimension of variable %s has sequence indices, but it is a state dimension.', var.dimID(d), var.name );
            
        % And that ensemble metadata is empty
        elseif ~isempty( var.ensMeta{d} )
            error('The %s dimension of variable %s has ensemble metadata, but it is a state dimension.', var.dimID(d), var.name );
        end
        
    % If an ensemble dimension
    else
        
        % Empty ensemble metadata is only permitted for no sequences
        if isempty( var.ensMeta{d} ) && numel(var.seqDex{d})>1
            error('The ensemble metadata for the %s dimension of variable %s is empty.', var.dimID(d), var.name );
        
        % and there should be one row of ensemble metadata for each sequence index
        elseif size( var.ensMeta{d}, 1) ~= numel(var.seqDex{d})
            error('The ensemble metadata for the %s dimension of variable %s does not have one row for each sequence index.', var.dimID(d), var.name);
        end
        
        % Check the sequence indices are allowed
        checkIndices( var, d, var.seqDex{d}+1 );
        checkIndices( var, d, var.meanDex{d}+1 );
        
        % (We don't need to bother checking if the sequences will fit on
        % the grid because this will be done when we try to draw ensemble
        % members.)
    end
end

end
