function[info] = nonscalarObj(obj, type)
%% dash.string.nonscalarObj  Return the disp header for a nonscalar DASH object
% ----------
%   info = dash.string.nonscalarObj(type)
%   Returns the header for console display of a non-scalar DASH object.
%   Includes the size or dimensionality of the array as appropriate.
%   Includes an "empty" tag if the object is empty.
% ----------
%   Inputs:
%       type (string scalar): The data type of the object
%
%   Outputs:
%       info (string scalar): The header of the object as printed by a
%           "disp" command.
%
%   <a href="matlab:dash.doc('dash.string.nonscalarObj')">Documentation Page</a>

%%% Parameter
maxDims = 4;
%%%

% Either print size or dimensionality
N = ndims(obj);
if N <= maxDims
    siz = dash.string.size(size(obj));
else
    siz = sprintf('%.f-D', N);
end

% Add "empty" tag to empty objects
if isempty(obj)
    empty = 'empty ';
else
    empty = '';
end

% Include "array" tag
info = sprintf('  %s %s%s array\n\n', siz, empty, type);

end