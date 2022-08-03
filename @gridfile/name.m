function[name] = name(obj)
%% gridfile.name  Return the name of the .grid file, excluding path
% ----------
%   name = <strong>obj.name</strong>
%   Returns the filename of the .grid file associated with the current
%   gridfile object. Filename will not include the path or extension.
% ----------
%   Outputs:
%       name (string scalar): The name of the gridfile
%
% <a href="matlab:dash.doc('gridfile.name')">Documentation Page</a>

% Setup
header = 'DASH:gridfile:name';
dash.assert.scalarObj(obj, header);
obj.assertValid(header);

% Get file name
[~,name] = fileparts(obj.file);

end