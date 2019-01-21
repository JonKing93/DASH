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
if any(d.syncMean(v,:)) || any(d.syncState(v,:)) || any(d.syncSeq(v,:))
    fprintf('\t\tSynced Variables:\n');
    
    if any(d.coupleState(v,:))
        fprintf('\t\t\tstate:    ');
        disp( d.varName( d.syncState(v,:) )' );
        fprintf('\b');
    end
    
    if any(d.coupleSeq(v,:))
        fprintf('\t\t\tsequence: ');
        disp( d.varName( d.syncSeq(v,:))');
        fprintf('\b');
    end
    
    if any(d.coupleMean(v,:))
        fprintf('\t\t\tmean:     ');
        disp( d.varName( d.coupleMean(v,:))');
        fprintf('\b');
    end
end

% Dimensions
fprintf('\t\tDimensions:\n');

% Display the dimensions
for k = 1:numel(dim)
    dispDimension( d.var(v), dim(k), longform );
end

end