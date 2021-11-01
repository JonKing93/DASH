function[] = save(obj)
%% gridfile.save  Save a gridfile object to a .grid file.
% ----------
%   <strong>obj.save</strong>
%   Saves the contents of the current gridfile object to its associated
%   .grid file.
% ----------
%
% <a href="matlab:dash.doc('gridfile.updateMetadataField')">Documentation Page</a>

% Save the values
dims = obj.dims;
isdefined = obj.isdefined;
gridSize = obj.size;
metadata = obj.meta;
source = obj.source;
fieldLength = obj.fieldLength;
maxLength = obj.maxLength;
dimLimit = obj.dimLimit;
absolutePath = obj.absolutePath;
save(obj.file, '-mat', 'dims','isdefined','gridSize','metadata','source','fieldLength','maxLength','dimLimit','absolutePath');

% Update the user object
obj.update;

end