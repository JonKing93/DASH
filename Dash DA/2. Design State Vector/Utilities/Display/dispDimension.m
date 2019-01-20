function[] = dispDimension(var, d, long)

% Dimension name
fprintf('\t\t\t%s\n', var.dimID{d});

% Size
fprintf('\t\t\t\tSize: %0.f\n', var.dimSize(d) );

% State dimensions
if var.isState(d)
    
    % Type
    fprintf('\t\t\t\tType: State\n');
    
    % Set by
    if var.dimSet(d)
        fprintf('\t\t\t\tSet By: User\n');
    else
        fprintf('\t\t\t\tSet By: Default\n');
    end
    
    % Mean
    if var.takeMean(d)
        fprintf('\t\t\t\tMean: true\n')
        fprintf('\t\t\t\tNaN Flag: %s\n', var.nanflag{d});
    else
        fprintf('\t\t\t\tMean: false\n');
    end
    
    % Index type
    dexType = 'State';
    
% Ensemble dimension
else
    
    % Type
    fprintf('\t\t\t\tType: Ensemble\n');
    
    % Set by
    if var.dimSet(d)
        fprintf('\t\t\t\tSet By: User\n');
    else
        fprintf('\t\t\t\tSet By: Default\n');
    end
    
    % Metadata
    fprintf('\t\t\t\tMetadata Value: ');
    disp( var.ensMeta{d} );
    fprintf('\b');
    
    % Sequence indices
    if ~isequal(var.seqDex{d}, 0)
        fprintf( ['\t\t\t\tSequence Indices: ', sprintf('%i, ',var.seqDex{d}), '\b\b\n'] );
    end
    
    % Mean indices
    if ~isequal(var.meanDex{d}, 0)
        fprintf( ['\t\t\t\tMean Indices: ', sprintf('%i, ', var.meanDex{d}), '\b\b\n'] );
    end
    
    % Index type
    dexType = 'Ensemble';
end

% Output the indices
if long
    fprintf( '\t\t\t\t%s Values: ', dexType);
    disp( var.meta.(var.dimID{d})(var.indices{d}) );
end

% Space for next line
fprintf('\n');

end