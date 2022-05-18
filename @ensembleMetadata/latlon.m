function[coordinates] = latlon(obj, siteColumns, variables)
%% ensembleMetadata.latlon  Return latitude-longitude coordinates for state vector elements
% ----------
%   coordinates = obj.latlon
%   Returns a latitude-longitude coordinate for each row of a state vector.
%   The output is a matrix with two columns - the first column holds the
%   latitude coordinate for each state vector row, and the second holds the
%   longitude coordinate. This method is a convenience function intended to
%   facilitate covariance localization. It prioritizes returning outputs
%   suitable for covariance localization over strictly reporting metadata.
%   Consider the "ensembleMetadata.rows" method for more rigorous metadata,
%   or if covariance localization is not your intent.
%
%   This method is designed for the case where latitude-longitude metadata
%   is stored along the "lat", "lon", and/or "site" dimensions. Coordinates
%   that are not well-described by numeric scalars are returned as NaN.
%
%   The method acts by obtaining "lat" and "lon" metadata for each
%   state vector element. To return a non-NaN coordinate for a state
%   vector element, the "lat" and "lon" metadata for the element must be
%   numeric scalars, string scalars, or char row vectors. In the case of
%   string scalars or char rows vectors, the strings are converted to
%   numeric coordinates using Matlab's "str2double" function. If the state
%   vector element does not have "lat" or "lon" metadata, the metadata is
%   not one of the described formats, or the metadata cannot be
%   converted to numeric coordinates, then the coordinates for the state
%   vector element are returned as NaN. If a state vector element
%   implements a mean over the "lat" or "lon" dimension, then the
%   coordinate for the dimension is also set to NaN.
%
%   coordinates = obj.latlon(siteColumns)
%   This syntax allows the method to also extract coordinates that are
%   stored along the "site" dimension. The input is a row vector with two
%   elements. The two elements indicate which columns of the "site"
%   metadata should be used for latitude and longitude coordinates. 
% 
%   Note that this syntax prioritizes "lat" and "lon" metadata over "site"
%   metadata. The metadata will only extract coordinates from the "site"
%   dimension when a state vector element has neither "lat" nor "lon" as a state
%   dimension. If the element also does not have "site" metadata, the
%   "site" metadata does not have the specified columns, the "site"
%   metadata cannot be converted to numeric coordinates, or there is a mean
%   over the "site" dimension, then the latitude-longitude coordinate is
%   returned as NaN.
%
%   coordinates = obj.latlon(siteColumns, variableNames)
%   coordinates = obj.latlon(siteColumns, v)
%   Indicate which columns of "site" metadata to use for specific
%   variables. If the first input has a single row, then uses the same
%   columns for all listed variables. Otherwise, the first input should
%   have one row per listed variable.
%
%   This syntax prioritizes "site" metadata for the listed variables. For
%   these variables, the method will only extract coordinates from "site" 
%   metadata and will ignore "lat" and "lon" metadata even if the state
%   vector element does not have "site" as a state dimension. For all other
%   variables, the method will only extract coordinates from "lat" and
%   "lon", even if the other variables have "site" as a state dimension.
% ----------

% Setup
header = "DASH:ensembleMetadata:latlon";
dash.assert.scalarObj(obj, header);

% Initial error checking of siteColumns
if exist('siteColumns','var')
    dash.assert.type(siteColumns, 'numeric', 'siteColumns', header);
    dash.assert.positiveIntegers(siteColumns, 'siteColumns', header);
    if size(siteColumns, 2) ~= 2
        requireTwoColumnsError;
    end
end

% Get dimension names
dims = gridMetadata.dimensions;
lon = dims(1);
lat = dims(2);
site = dims(4);

% Preallocate site dimensions and columns. Get dimension names
useSite = false(obj.nVariables, 1);
columns = NaN(obj.nVariables, 2);

% Error check when the user specifies variables
if exist('variables','var')
    vars = obj.variableIndices(variables, false, header);
    nVars = numel(vars);
    useSite(vars) = true;

    % Parse site columns
    nCols = size(siteColumns, 1);
    if ~ismatrix(siteColumns)
        columnsNotMatrixError;
    elseif nCols~=1 && nCols~=nVars
        wrongNumberOfColumnsError;
    elseif nCols==1
        columns(vars,:) = repmat(siteColumns, nVars, 1);
    else
        columns(vars,:) = siteColumns;
    end

% Error check when the user only provides columns
elseif exist('siteColumns','var')
    dash.assert.vectorTypeN(siteColumns, [], [], 'siteColumns', header);
    
    % Determine which set of dimensions to use for each variable
    for v = 1:obj.nVariables
        if ~ismember(lat, obj.stateDimensions{v}) && ~ismember(lon, obj.stateDimensions{v})
            useSite(v) = true;
        end
    end
    columns(useSite,:) = repmat(siteColumns, sum(useSite), 1);
end

% Preallocate the coordinates
nRows = obj.length;
coordinates = NaN(nRows, 2);

% Cycle though variables, get rows for each variable
for v = 1:obj.nVariables
    rows = obj.find(v);

    % Get coordinates from site dimension or lat-lon
    if useSite(v)
        coordinates(rows,:) = obj.getLatLon(v, site, columns(v,:));
    else
        coordinates(rows,:) = obj.getLatLon(v, [lat,lon]);
    end
end

end