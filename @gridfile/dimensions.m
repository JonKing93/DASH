function[dimensions, sizes] = dimensions(obj)
%% gridfile.dimensions  Return the dimensions in gridfile and their sizes
% ----------
%   <strong>obj.dimensions</strong>
%   Prints the names, sizes, and (when possible) metadata limits of
%   gridfile dimensions to the console.
%   
%   dimensions = <strong>obj.dimensions</strong>
%   Return the list of dimensions in a .grid file.
%
%   [dimensions, sizes] = <strong>obj.dimensions</strong>
%   Also returns the size of each dimension.
% ----------
%   Outputs:
%       dimensions (string vector): The dimensions in a gridfile
%       sizes (vector, positive integers): The size of each dimension in
%           the gridfile.
%
% <a href="matlab:dash.doc('gridfile.dimensions')">Documentation Page</a>

% Setup
header = "DASH:gridfile:dimensions";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Console display
if nargout==0
    fprintf('\n    Dimension Sizes and Metadata for gridfile "%s":\n',obj.name);
    obj.dispDimensions;

% Or return values
else
    dimensions = obj.dims;
    sizes = obj.size;
end

end