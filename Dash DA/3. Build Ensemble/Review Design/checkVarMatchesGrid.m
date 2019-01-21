function[] = checkVarMatchesGrid( var )

% Get gridfile metadata
[meta, dimID, dimSize] = metaGridfile( var.file );

% Common warning message
warn = 'The gridfile may have been edited after initializing the variable.';

% Check each for equality
if ~isequaln( meta, var.meta )
    error('Metadata in gridfile %s does not match the metadata in variable %s.\n%s'],...
        var.file, var.name, warn);
end

% Check ordering
if ~isequal( dimID, var.dimID )
    error('Dimensional ordering gridfile %s does not match variable %s.\n%s', ...
        var.file, var.name, warn );
end

% Check size
if ~isequal( dimSize, var.dimSize )
    error('Dimension sizes in gridfile %s do not match variable %s.\n%s', ...
        var.file, var.name, warn );
end

end
        
         