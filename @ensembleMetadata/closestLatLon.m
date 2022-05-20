function[rows] = closestLatLon(obj, variable, coordinates, varargin)
%% ensembleMetadata.closestLatLon  Locate the rows of a variable that are closest to a latitude-longitude coordinate
% ----------
%   rows = obj.closestLatLon(variableName, coordinates)
%   rows = obj.closestLatLon(v, coordinates)
%   Given a variable in the state vector, locates the rows of the variable
%   that are closest to a given latitude-longitude coordinate. Returns the
%   indices of these rows in the overall state vector. If multiple rows are
%   tied as the closest, returns all of the tied rows.
%
%   This method proceeds by collecting latitude-longitude coordinates for
%   the variable from the "lat" and "lon" dimensions. The distances between
%   the variable's coordinates and the input coordinate are then calculated
%   using a haversine function. The haversine function accomodates both
%   -180:180 and 0:360 longitude coordinate systems. Thus, you may use
%   either coordinate system, or even a mix of both.
%  
%   The method determines latitude-longitude coordinates for the variable
%   using the procedure outlined in the "ensembleMetadata.latlon" method.
%   See the documentation of "ensembleMetadata.latlon" for details. Throws
%   an error if the extracted coordinates are complex valued. Allows NaN
%   and Inf coordinates, so long as at least one extracted coordinate is
%   well-defined. If all extracted coordinates include NaN or Inf values, 
%   throws an error.
%
%   rows = obj.closestLatLon(..., 'site', columns)
%   Indicates that the method should extract latitude-longitude coordinates
%   from the columns of the "site" dimension, rather than the "lat" and
%   "lon" dimensions. Here, the "columns" input is a vector with two
%   elements. The first element indicates the column of the "site" metadata
%   that contains latitude coordinates, and the second element is the
%   column with longitude coordinates. See the documentation of
%   "ensembleMetadata.latlon" for additional details on how coordinates are
%   determined from "site" metadata.
%
%   rows = obj.closestLatLon(..., 'exclude', variableRows)
%   Indicate rows of the variable that should be excluded from
%   consideration. Note that variableRows are interpreted relative to the
%   variable, rather than the overall state vector. For example, if
%   variableRows=1, the method will exclude the first row of the variable,
%   regardless of its overall position in the state vector. By contrast,
%   the output rows *do* indicate positions in the overall state vector.
%   
%   This syntax is often combined with the "ensembleMetadata.variable"
%   command, which returns metadata for individual variables in the state
%   vector. The outputs of that command can be used to search for excluded
%   values within the context of a single variable.
% ----------
%   Inputs:
%       variableName (string scalar): The name of the variable for which to
%           find the closest latitude-longitude points.
%       v (logical vector | scalar linear index): The index of the variable
%           in the state vector. If a logical vector, must have one element
%           per variable in the state vector and exactly one true element.
%       coordinates (numeric vector [2]): The coordinate for which to find
%           the closest point (in decimal degrees). A vector with two elements. 
%           The first element is latitude and the second is longitude.
%       columns (vector positive integers [2]): Indicates which columns of
%           the "site" metadata for the variable hold the latitude and
%           longitude coordinates. The first element is the latitude
%           column, and the second element is the longitude column.
%       variableRows (logical vector | vector, linear indices): Indicates
%           the rows of the variable that should be excluded from
%           consideration as the closest point. Either a logical vector
%           with one element per row of the variable, or a vector of linear
%           indices.
%
%   Outputs:
%       rows (vector, linear indices): The rows of the overall state vector that
%           correspond to the closest latitude-longitude points for the 
%           listed variable.
%
% <a href="matlab:dash.doc('ensembleMetadata.closestLatLon')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:closestLatLon";
dash.assert.scalarObj(obj, header);

% Check the variable
v = obj.variableIndices(variable, false, header);
if numel(v)~=1
    tooManyVariablesError(obj, v, header);
end

% Error check the coordinates
dash.assert.vectorTypeN(coordinates, 'numeric', 2, 'coordinates', header);
dash.assert.defined(coordinates, 1, 'coordinates', header);

% Parse the optional arguments
[columns, exclude] = dash.parse.nameValue(varargin, ["site","exclude"], {[],[]}, 2, header);

% Check the site columns
if isempty(columns)
    useSite = false;
else
    useSite = true;
    dash.assert.vectorTypeN(columns, 'numeric', 2, 'columns', header);
    dash.assert.positiveIntegers(columns, 'columns', header);
end

% Check the excluded rows
if isempty(exclude)
    exclude = [];
else 
    logicalReq = sprintf('have one element per row of the "%s" variable', obj.variables_(v));
    linearMax = sprintf('the length of the "%s" variable', obj.variables_(v));
    exclude = dash.assert.indices(exclude, obj.lengths(v), 'exclude', logicalReq, linearMax, header);
end

% Get the rows under consideration
variableRows = (1:obj.lengths(v))';
variableRows(exclude) = [];
if numel(variableRows)==0
    allRowsExcludedError(obj, v, header);
end

% Determine latitude-longitude coordinates from site or lat-lon dimensions
dimensions = gridMetadata.dimensions;
if useSite
    site = dimensions(4);
    variableCoordinates = obj.getLatLon(v, variableRows, site, columns);
else
    latlon = dimensions(1:2);
    variableCoordinates = obj.getLatLon(v, variableRows, latlon);
end

% Require real valued coordinates
if ~isreal(variableCoordinates)
    complexCoordinatesError(obj, v, header);
end

% Get the distances to the input coordinates
if iscolumn(coordinates)
    coordinates = coordinates';
end
distances = dash.math.haversine(variableCoordinates, coordinates);

% Require at least one well-defined value
if all(isnan(distances))
    undefinedCoordinatesError(obj, v, header);
end

% Locate the closest elements within the overall state vector
closest = distances == min(distances);
variableRows = variableRows(closest);
startRow = obj.find(v, 'start');
rows = variableRows + startRow - 1;

end

% Error messages
function[] = tooManyVariablesError(obj, v, header)
variables = obj.variables_(v);
variables = dash.string.list(variables);
id = sprintf('%s:tooManyVariables', header);
ME = MException(id, ['You must list exactly 1 variable, but you have specified ',...
    '%.f variables (%s).'], numel(v), variables);
throwAsCaller(ME);
end
function[] = allRowsExcludedError(obj, v, header)
id = sprintf('%s:allRowsExcluded', header);
ME = MException(id, ['Cannot find the closest latitude-longitude point because you have ',...
    'excluded all the rows of the "%s" variable from consideration.'], obj.variables_(v));
throwAsCaller(ME);
end
function[] = complexCoordinatesError(obj, v, header)
id = sprintf('%s:complexValuedCoordinates', header);
ME = MException(id, ['The coordinates for the "%s" variable appear to be complex ',...
    'valued, and so cannot be used with the haversine function.'], obj.variables_(v));
throwAsCaller(ME);
end
function[] = undefinedCoordinatesError(obj, v, header)
id = sprintf('%s:undefinedCoordinates', header);
ME = MException(id, ['All the coordinates extracted for the "%s" variable ',...
    'contain NaN or Inf elements.'], obj.variables_(v));
throwAsCaller(ME);
end