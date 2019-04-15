function[] = checkVarMatchesGrid( var )
%% Ensure the gridfile has not been altered since the design was created.
%
% var: varDesign
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get gridfile metadata. (This will also error check the file name).
[meta, dimID, dimSize] = metaGridfile( var.file );

% Common warning message
warn = 'The .grid file may have been edited after creating the stateDesign.';

% Check each for metadata equality
if ~isequaln( meta, var.meta )
    error('Metadata in file %s does not match the metadata for variable %s.\n%s',...
        var.file, var.name, warn);
end

% Check dimension order
if ~isequal( dimID, var.dimID )
    error('Dimensional ordering in file %s does not match variable %s.\n%s', ...
        var.file, var.name, warn );
end

% Check size
if ~isequal( dimSize, var.dimSize )
    error('Dimension sizes in file %s do not match variable %s.\n%s', ...
        var.file, var.name, warn );
end

end