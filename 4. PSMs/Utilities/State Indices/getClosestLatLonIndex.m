function[H] = getClosestLatLonIndex( coord, ensMeta, varNames, varargin )
%% Gets the state indices closest to a particular lat-lon coordinate from
% an ensemble for a set of variables. May optionally specify additional
% indices along other dimensions along which to extract indices. (In
% process of writing better documentation -- for now, please ask for any
% questions on how this works.)
%
% H = getClosestLatLonIndex( coord, ensMeta, varNames )
% Finds the closest state indices to a set of coordinates for a set of
% variables.
%
% H = getClosestLatLonIndex( coord, ensMeta, varNames, 'dimName', indices )
% Finds H at each of a set of specified indices along other dimensions.
%
% ----- Inputs -----
%
% coord: A set of lat-lon coordinates.
%
% ensMeta: A set of ensemble metadata
%
% varNames: A set of variable names. Must be a string column.
%
% dimName: A dimension ID
%
% indices: The indices within the ensemble metadata along which to search
%          state indices.
%
% ----- Outputs -----
%
% H: A set of state indices.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

%% Do a general call to parseInputs to get restriction values

% Start by getting the names of all the dimension IDs
[dimID,~,~,lon,lat,~,~,~,tri] = getDimIDs;
nDim = numel(dimID);
norestrict = [lon;lat;tri];

% Preallocate args for call to parseInputs
restrict = cell( nDim, 1 );
empty = repmat( {[]}, [nDim, 1] );

% Get the restriction values for each dimension
[restrict{:}] = parseInputs( varargin, cellstr(dimID), empty, empty );


%% Get combination indices for each set of restriction values

% Preallocate the number of restriction indices per dimension
nEls = zeros( nDim, 1 );

% For each dimension
for d = 1:nDim
    
    % Check that lat, lon, and tri do not have restriction values
    if ismember(dimID(d), norestrict) && ~isempty(restrict{d})
        error('Restriction values are not allowed for the %s dimension.', norestrict(d) );
    end
    
    % Get the number of restrictions
    nEls(d) = size( restrict{d}, 1 );
end

% Reduce to restriction dimensions
resDim = find( nEls~=0 );
nResDim = numel(resDim);
nEls = nEls( resDim );

% Get the set of combinations
combDex = subdim( nEls, (1:prod(nEls))' );

% Preallocate the number of H indices
nComb = size(combDex,1);
nVar = numel(varNames);
H = NaN( nComb*nVar, 1 );


%% Get the closest index for the lat, lon metadata for each variable

% For each variable
for var = 1:numel(varNames)
    
    % Get the variable index
    v = varCheck( ensMeta, varNames(var) );
    
    % Get the lat-lon metadata
    latlon = getLatLonMetadata( ensMeta, varNames(var) );
    
    % Determine the ensemble lat-lon values closest to the coordinates
    site = samplingMatrix( coord, latlon, 'linear' );
    
    
    %% Modulate over restriction indices
    
    % Initialize restriction indices, number of modulus indices per
    % dimension, and the indices for each combination
    restrictDex = cell( nResDim, 1 );
    nModulus = NaN( 1, nResDim );
    resComb = combDex;
    
    % For each dimension with restriction values
    for dim = 1:nResDim
        d = resDim(dim);
            
        % Get the associated restriction indices
        [~, restrictDex{dim}] = ismember( restrict{d}, ensMeta.var(v).(dimID(d)) );
        
        % Check that every index had appropriate metadata
        if any( restrictDex{dim} == 0 )
            error('Variable %s does not have the appropriate metadata along the %s dimension.', varNames(var), dimID(d) );
        end

        % Get the modulus number and number of restrictions
        nModulus(dim) = prod( ensMeta.varSize(v,1:d-1) );
        
        % Get the restriction indices for each combination
        resComb(:,dim) = restrictDex{dim}(combDex(:,dim));
    end

    % Modulate over restriction indices to get the H indices for the variable
    H((var-1).*nComb+(1:nComb)) = (ensMeta.varLim(v,1) - 1) + sum( (resComb-1).*nModulus, 2 ) + site;
end
    
