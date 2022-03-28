function[indicesName, dimensionName] = indexedDimension(dimensionName, d, multipleDimensions)
%% dash.string.indexedDimension  Names for indices and dimensions in sets of indexed dimensions
% ----------
%   indicesName = dash.string.indexedDimension(dimensionName, d, multipleDimensions)
%   Returns a name for a set of indices being used to index a dimension.
%   References the dimenion by name when possible. If no dimension name is
%   provided and there are multiple dimensions, notes which dimension is
%   associated with the indices.
%
%   [indicesName, dimensionName] = dash.string.indexedDimension(...)
%   Also returns a name for the dimension being indexed.
% ----------
%   Inputs:
%       dimensionName (string scalar): The name of the dimension being indexed
%       d (scalar positive integer): The index of the dimension within a
%           set of indexed dimensions.
%       multipleDimensions (scalar logical): True if multiple dimensions
%           are indexed. Otherwise false.
%
%   Outputs:
%       indicesName (string scalar): A name for the set of indices.
%       dimensionName (string scalar): A name for the dimension
%
% <a href="matlab:dash.doc('dash.string.indexedDimension')">Documentation Page</a>

% Get the dimension name
if ~strcmp(dimensionName, "")
    dimensionName = sprintf('the "%s" dimension', dimensionName);

% Or use a placeholder
else
    if multipleDimensions
        dimensionName = sprintf('indexed dimension %.f', d);
    else
        dimensionName = 'the dimension';
    end
end

% Get the name for the indices
indicesName = sprintf('the indices for %s', dimensionName);

end