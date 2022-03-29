function[rows] = closestLatLon(obj, latlon, varName, exclude, verbose)
%% Returns the state vector rows closest to a set of lat-lon coordinates
%
% rows = obj.closestLatLon( coordinate )
% Returns the state vector rows closest to the given coordinate.
%
% rows = obj.closestLatLon( coordinate, varName )
% Returns the state vector rows that are closest to the given coordinate
% for a particular variable.
%
% rows = obj.closestLatLon( coordinate, varName, exclude )
% Specify rows that should not be selected as the closest
% latitude-longitude point.
%
% rows = obj.closestLatLon( coordinate, varName, exclude, verbose )
% Optionally disable console messages.
%
% ----- Inputs -----
%
% coordinate: A latitude-longitude coordinate. A vector with two elements.
%    The first element is the latitude coordinate and the second element is
%    the longitude coordinate.
%
% varName: The name of a variable in the state vector ensemble. A string.
%
% exclude: A logical matrix that indicates which state vector elements to
%    exclude from consideration. Must have one row per state vector
%    element or one row per state vector element for the specified
%    variable, as appropriate.
%
% verbose: A scalar logical that indicates whether to return console
%    messages when determining coordinates (true -- default) or not (false)
%
% ----- Outputs -----
%
% rows: The rows of the state vector that are closest to the selected
%    lat-lon coordinate.

% Defaults
if ~exist('varName','var') || isempty(varName)
    varName = [];
end
if ~exist('verbose','var') || isempty(verbose)
    verbose = [];
end

% Error check the user-specified coordinate
assert( isnumeric(latlon) & isvector(latlon), 'latlon must be a numeric vector.');
assert(numel(latlon)==2, 'latlon must have two elements.');
dash.assert.realDefined(latlon, 'latlon');
assert(abs(latlon(1))<=90, 'latitude coordinates must be between -90 and 90.');

% Get the state vector lat-lon coordinates and get the distance to each
svLatLon = obj.latlon(varName, verbose);
nState = size(svLatLon, 1);
dist = dash.distance.haversine(svLatLon, latlon);

% Default and error check exclude
if ~exist('exclude','var') || isempty(exclude)
    exclude = false(nState, 1);
end
assert(islogical(exclude) && ismatrix(exclude), 'exclude must be a logical matrix');
assert(size(exclude,1)==nState, sprintf('exclude must have %.f rows (one per state vector element', nState));
nCols = size(exclude, 2);

% Find the state vector rows associated with the minimum distances for each
% set of excluded indices
for m = 1:nCols
    currentDist = dist;
    currentDist(exclude(:,m)) = NaN;
    currentRows = find( currentDist == min(currentDist) );
    nRows = numel(currentRows);
    
    % Preallocate the rows for each ensemble member
    if m==1
        rows = NaN(nRows, nCols);
    end
    
    % If there are more rows than fit in rows, preallocate more NaN
    % rows for the other sets of excluded indices
    nAdd = max( nRows-size(rows,1),  0 );
    if nAdd > 0
        rows = [rows; NaN(nAdd, nCols)]; %#ok<AGROW>
    end
    
    % Convert variable rows to state vector rows and save
    if ~isempty(varName)
        currentRows = obj.findRows(varName, currentRows);
    end
    rows(1:nRows, m) = currentRows;
end

end