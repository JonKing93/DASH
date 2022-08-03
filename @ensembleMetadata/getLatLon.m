function[coordinates] = getLatLon(obj, v, variableRows, dimensions, columns)
%% ensembleMetadata.getLatLon  Return latitude-longitude coordinates for a variable
% ----------
%   coordinates = obj.getLatLon(v, variableRows, ...)
%   Obtains latitude-longitude coordinates at the specified rows of avariable in a state
%   vector. Extracts coordinates from either the lat and lon dimensions, or
%   from the site dimension. If the variable is missing the required
%   dimensions, returns NaN coordinates. Also returns NaN coordinates if
%   the variable implements a mean over the dimensions. Expects the
%   lat/lon coordinate metadata for each row to either be a numeric scalar,
%   string scalar, or char row vector. Returns NaN coordinates if the
%   metadata does not follow this format. If the coordinate metadata is
%   string or char, converts the coordinate to a numeric format using the
%   "str2double" function. If the coordinate cannot be converted, uses a
%   NaN coordinate for the row.
%
%   coordinates = obj.getLatLon(v, variableRows, latlonDimensions)
%   Extracts coordinate metadata from the lat and lon dimensions.
%
%   coordinates = obj.getLatLon(v, variableRows, siteDimension, columns)
%   Extracts coordinate metadata from the site dimension. Coordinates are
%   extracted from the indicated columns of the metadata. If the site
%   metadata is missing a column, returns NaN for that coordinate.
% ----------
%   Inputs:
%       v (scalar linear index): The index of a variable in the state vector
%       variableRows (vector, linear indices): Rows of the variable at
%           which to return latitude-longitude coordinates. These rows are
%           interpreted relative to the variable, rather than the overall
%           state vector.
%       latlonDimensions (string vector [2]): The names of the lat and lon
%           dimension. First element is lat, and second element is lon.
%       siteDimension (string scalar): The name of the site dimension
%       columns (vector [2], positive integers | NaN): If extracting
%           coordinates from the site dimension, indicates which columns of
%           site metadata hold the latitude and longitude coordinates. The
%           first element is latitude and the second element is longitude.
%           This input is ignored when extracting metadata from the lat and
%           lon dimensions.
%
%   Outputs:
%       coordinates (numeric matrix [nVariableRows x 2]): The latitude and
%           longitude coordinate for each row of the variable. A matrix
%           with two columns. The first column holds the latitude points,
%           and the second column holds longitude.
%
% <a href="matlab:dash.doc('ensembleMetadata.getLatLon')">Documentation Page</a>

% Preallocate coordinates
nRows = numel(variableRows);
coordinates = NaN(nRows, 2);

% Use the number of dimensions to determine site vs lat-lon
if numel(dimensions)==1
    useSite = true;
    site = dimensions;
else
    useSite = false;
    lat = dimensions(1);
    lon = dimensions(2);
end

% Only extract metadata if dimensions are present and do not implement means.
dimensions = obj.stateDimensions{v};
if ~useSite
    [hasLat, dLat] = ismember(lat, dimensions);
    [hasLon, dLon] = ismember(lon, dimensions);
    useLat = hasLat && obj.stateType{v}(dLat)~=1;
    useLon = hasLon && obj.stateType{v}(dLon)~=1;
    if ~useLat && ~useLon
        return
    end
else
    [hasSite, dSite] = ismember(site, dimensions);
    if ~hasSite || obj.stateType{v}(dSite)==1
        return
    end

    % If using site metadata, also exit if both columns are missing
    nCols = size(obj.state{v}{dSite}, 2);
    if nCols < min(columns)
        return
    end
end

% Get subscripted indices along the dimensions of the variable
subIndices = obj.subscriptRows(v, variableRows);

% If using site dimension, get site indices
if useSite
    indices = subIndices{dSite};

    % Latitude metadata
    if nCols >= columns(1)
        metadata = obj.state{v}{dSite}(indices, columns(1));
        coordinates(:,1) = meta2coord(metadata);
    end

    % Longitude metadata
    if nCols >= columns(2)
        metadata = obj.state{v}{dSite}(indices, columns(2));
        coordinates(:,2) = meta2coord(metadata);
    end

% Otherwise, get lat metadata
else
    if useLat
        indices = subIndices{dLat};
        metadata = obj.state{v}{dLat}(indices, :);
        coordinates(:,1) = meta2coord(metadata);
    end

    % And lon metadata
    if useLon
        indices = subIndices{dLon};
        metadata = obj.state{v}{dLon}(indices, :);
        coordinates(:,2) = meta2coord(metadata);
    end
end

end

%% Utilities
function[coord] = meta2coord(coord)
%% Convert metadata to numeric coordinates

% Require a char matrix or numeric/string column vector
if    (ismatrix(coord) && ischar(coord))      ...                    % Char matrix
   || (iscolumn(coord) && (isnumeric(coord) || isstring(coord)))   % Numeric or string column vector
   
    % Convert char to string
    if ischar(coord)
        coord = string(coord);
    end
    
    % Convert strings to doubles
    if isstring(coord)
        coord = str2double(coord);
    end

% Otherwise, just return NaN
else
    coord = NaN;
end

end