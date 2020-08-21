function[] = save(obj)
%% Saves the values in a gridfile object to file.

% Save the values
dims = obj.dims;
isdefined = obj.isdefined;
gridSize = obj.size;
metadata = obj.meta;
source = obj.source;
fieldLength = obj.fieldLength;
maxLength = obj.maxLength;
dimLimit = obj.dimLimit;
save(obj.file, '-mat', 'dims','isdefined','gridSize','metadata','source','fieldLength','maxLength','dimLimit');

% Update the user object
obj.update;

end