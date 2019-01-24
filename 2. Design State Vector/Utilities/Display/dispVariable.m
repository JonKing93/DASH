function[] = dispVariable( d, v, dim, longform )

% Get the variables
if strcmp(dim,'all')
    dim = 1:numel(d.var(v).dimID);
end

% Variable name 
fprintf('\t%s\n', d.var(v).name  );

% Reference file
fprintf( '\t\tGridfile: %s\n', d.var(v).file );

% Coupled Varialbes
if any( d.isCoupled(v,:) )
    fprintf( '\t\tCoupled Variables: ' );
    disp( d.varName( d.isCoupled(v,:) ) );
    fprintf('\b');
end

% Synced Variables
if any(d.isSynced(v,:))
    fprintf('\t\tSynced Variables:\n');
    disp( d.varName( d.isSynced(v,:) ) );
    fprintf('\b');
end

% Overlap
if d.var(v).overlap
    overStr = 'Allowed';
else
    overStr = 'Forbidden';
end
fprintf('\t\tEnsemble overlap: %s\n', overStr);

% Dimensions
fprintf('\t\tDimensions:\n');

% Display the dimensions
for k = 1:numel(dim)
    dispDimension( d.var(v), dim(k), longform );
end

end