function[] = update( obj )
% Ensures that a grid object matches the associated file.

% Check that the file still exists
try
    grid = obj.fileCheck( obj.filepath );
catch
    delete(obj);
    error('The grid file does not exist. It may have been deleted or removed from the active path. Deleting the current gridFile object.');
end

% Update the properties
try    
    obj.dimOrder = grid.dimOrder;
    obj.gridSize = grid.gridSize;
    obj.metadata = grid.metadata;
    obj.dimLimit = grid.dimLimit;
    obj.nSource = grid.nSource;
catch ME
    delete(obj);
    error('The grid file is not valid. It may have been modified externally or failed during a write operation. Deleteing the current gridFile object.');
end

end