function[name] = name(obj)
%% gridfile.name  Return the name of the .grid file, excluding path
% ----------
%   name = obj.name
%   Returns the filename of the .grid file associated with the current
%   gridfile object. Filename will not include the path or extension.
% ----------
[~,name] = fileparts(obj.file);
end