function[] = update( obj )

% Check that the file still exists
try
    obj.fileCheck( obj.filepath );
catch
    delete(obj);
    error('The grid file does not exist. It may have been deleted or removed from the active path. Deleting the current gridFile object.');
end

% Update the properties
try    
    grid = load(obj.filepath, '-mat', 'source','dimOrder','dimLimit','metadata','gridSize');

    obj.source = grid.source;
    obj.dimOrder = grid.dimOrder;
    obj.dimLimit = grid.dimLimit;
    obj.metadata = grid.metadata;
    obj.gridSize = grid.gridSize;
catch
    delete(obj);
    error('The grid file is not valid. It may have been modified externally or failed during a write operation. Deleteing the current gridFile object.');
end

end