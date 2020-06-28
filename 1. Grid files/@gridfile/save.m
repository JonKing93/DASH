function[] = save(obj)
%% Saves the values in a gridfile object to file.

% Save the values
valid = true;
dims = obj.dims;
gridSize = obj.size;
meta = obj.meta;
source = obj.source;
dimLimit = obj.dimLimit;
save(obj.file, '-mat', 'valid','dims','gridSize','meta','source','dimLimit');

% Update the user object
obj.update;

end