function[stateCoord] = getEnsembleCoords( ensMeta )

% Check that the ensemble metadata has the required fields
[~,~,var,lonDim,latDim,~,~,~,triDim] = getDimIDs;
if ~isstruct(ensMeta)
    error('ensMeta must be an ensemble metadata structure.');
elseif ~isfield( ensMeta, lonDim) || ~isfield(ensMeta,latDim) || ~isfield(ensMeta,triDim)
    error('Ensemble metadata must include the %s, %s, and %s fields.', lonDim, latDim, triDim);
end

% Get the number of state elements
nState = size(ensMeta, 1);

% Preallocate the lat and lon arrays
stateCoord = NaN( nState, 2 );

% Get the variables in the state vector
vars = unique( ensMeta.(var) );

% For each variable
for v = 1:vars

    % Get the indices associated with the variable
    varDex = strcmp( ensMeta.(var), vars(v) );

    % Get the lat-lon metadata.
    try
        stateCoord(varDex,:) = getLatLonMetadata( ensMeta, varDex, vars(v) );

    % The coordinates of spatial means are not defined. If the metadata has
    % a spatial mean, fill the coordinates with NaN.
    catch ME

        if strcmp( ME.identifier, 'DASH:MetadataSpatialMean' )
            stateCoord(varDex,:) = NaN;

        % But if some other error occurred, rethrow
        else
            rethrow(ME);
        end
    end
end

end

