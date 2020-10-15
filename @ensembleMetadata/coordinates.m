function[latlon] = coordinates(obj, verbose)
%% Returns lat-lon coordinate metadata down the state vector. Reads metadata
% from the "lat", "lon", and "coord" dimensions as appropriate. Returns NaN
% coordinates for any state vector elements that use a spatial mean or
% that lack lat-lon coordinate metadata.
%
% latlon = obj.coordinates
% Returns a lat-lon coordinate for each element of a state vector.
%
% latlon = obj.coordinates(verbose)
% Specify whether or not to print notifications to the console. Default is
% to display notifications.
%
% *** Requirements *** 
% 1. Metadata extracted from the "lat" and "lon" dimensions must be numeric
% and have a single column -- otherwise, NaN coordinates are returned.
%
% 2. Metadata extracted from the "coord" dimension must be numeric and have
% two columns (one column for lat, and one column for lon). The method will
% attempt to determine which column is lat and which column is lon
% automatically. If it cannot determine which column corresponds to which
% dimension, prints a notification to the console and uses the first column
% as latitude coordinates.
%
% ----- Inputs -----
%
% verbose: A scalar logical indicating whether to print notification
%    messages to the console (true -- default) or not (false).
%
% ----- Outputs -----
%
% latlon: A numeric matrix of lat-lon coordinates. Has one row per state
%    vector element and two columns. The first column contains latitude
%    coordinates and the second contains longitude coordinates. The
%    coordinates for any state vector element with a spatial mean, missing
%    coordinate metadata, or unrecognized coordinate format will be
%    returned as NaN.

% Default and error check
if ~exist('verbose','var') || isempty(verbose)
    verbose = true;
else
    dash.assertScalarType(verbose, 'verbose', 'logical', 'logical');
end
notified = false;

% Get the dimension names and variables. Preallocate the coordinates.
[~, lonName, latName, coordName] = dash.dimensionNames;
latlon = NaN(obj.varLimit(end), 2);

% Get state metadata for the variable
for v = 1:numel(obj.nEls)
    var = obj.variableNames(v);
    meta = obj.metadata.(var).state;
    
    % Check whether the metadata is stored as "lat" and "lon", or "coord"
    hasdim = false(1, 3); % lat, lon, coord
    dims = [lonName, latName, coordName];
    for d = 1:3
        if ismember(dims(d), obj.dims{v}) && (~isscalar(meta.(dims(d))) || ~isnan(meta.(dims(d))))
            hasdim(d) = true;
        end
    end
    
    % Notify user if there is both lat/lon and coord metadata
    hasdata = true;
    if (hasdim(1)||hasdim(2)) && hasdim(3)
        hasdata = false;
        if verbose
            bothMetadataTypesWarning(var, dims(find(hasdim,1)), coordName);
            notified = true;
        end
    
    % Notify if there is lat, but not lon, or vice versa
    elseif any(hasdim(1:2)) && ~all(hasdim(1:2))
        hasdata = false;
        if verbose
            missingHalfWarning(var, dims(find(hasdim,1)), dims(find(~hasdim,1)));
            notified = true;
        end
        
    % Notify if there is no metadata
    elseif all(~hasdim)
        hasdata = false;
        if verbose
            missingAllWarning(var, dims);
            notified = true;
        end
    end
    
    % Get lat-lon metadata. Check formatting and spatial means.
    if hasdata && ~hasdim(3)
        latMeta = obj.variable(var, dims(2), true);
        [hasdata, notified] = checkMetadata(latMeta, 1, var, dims(2), verbose, notified);
        if hasdata
            lonMeta = obj.variable(var, dims(1), true);
            [hasdata, notified] = checkMetadata(lonMeta, 1, var, dims(1), verbose, notified);
            varCoords = [latMeta, lonMeta];
        end
        
    % Otherwise, get coordinate metadata. Check format and spatial mean
    elseif hasdata
        coordMeta = obj.variable(var, dims(3), true);
        [hasdata, notified] = checkMetadata(coordMeta, 2, var, dims(3), verbose, notified);
        
        % Attempt to determine which column is lat and which is lon
        if hasdata
            over90 = any(abs(coordMeta)>90,1);
            
            % Notify user if using default
            if all(over90) || all(~over90)
                if verbose
                    notifyDefaultColumn(var, dims(3));
                    notified = true;
                end
                
            % Otherwise, set columns and notify
            else
                latcol = find(~over90);
                loncol = find(over90);
                varCoords = coordMeta(:, [latcol, loncol]);
                if verbose
                    notifySelectedColumn(var, dims(3), latcol, loncol);
                    notified = true;
                end
            end
        end
    end
    
    % If everything was successful, add the coordinates to the output
    if hasdata
        rows = obj.varLimit(v,1):obj.varLimit(v,2);
        latlon(rows,:) = varCoords;
    end    
end

% Format the console after messages
if notified
    fprintf('\n');
end

end

% Helper function to support DRY code
function[hasdata, notified] = checkMetadata(meta, nCols, var, dim, verbose, notified)
           
% Check numeric with correct columns
hasdata = true;
if ~isnumeric(meta) || size(meta,2)~=nCols
    hasdata = false;
    if verbose
        fprintf(['\nUsing NaN coordinates for "%s" because the metadata for ',...
            'the "%s" dimension is not a numeric marix with %.f column(s).'],...
            var, dim, nCols);
        notified = true;
    end
    
% Check for spatial mean
elseif size(meta,3)~=1
    hasdata = false;
    if verbose
        fprintf(['\nUsing NaN coordinates for "%s" because it takes a spatial ',...
            'mean over the "%s" dimension.'], var, dim);
        notified = true;
    end
end

end

% Long warnings
function[] = bothMetadataTypesWarning(var, dim1, dim2)
fprintf(['\nUsing NaN coordinates for "%s" because it has metadata for both ',...
    'the "%s" and "%s" dimensions.'], var, dim1, dim2);
end
function[] = missingHalfWarning(var, dim1, dim2)
fprintf(['\nUsing NaN coordinates for "%s" because it has metadata for the ',...
    '"%s" dimension, but not the "%s" dimension.'], var, dim1, dim2);
end
function[] = missingAllWarning(var, dims)
fprintf(['\nUsing NaN coordinates for "%s" because it does not have metadata ',...
    'for any of the "%s", "%s", or "%s" dimensions.'], var, dims(1), dims(2), dims(3));
end
function[] = notifyDefaultColumn(var, dim)
fprintf('\nCould not determine which column of the "%s" metadata for ',...
    'variable "%s" is for latitude, and which column is for longitude.',...
    'Using the first column as latitude coordinates.', dim, var);
end
function[] = notifySelectedColumn(var, dim, latcol, loncol)
fprintf(['\nFor the "%s" metadata of variable "%s": Using column %.f for ',...
    'latitude, and column %.f for longitude.\n'], dim, var, latcol, loncol);
end     