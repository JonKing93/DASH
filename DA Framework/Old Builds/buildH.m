function[H] = buildH( modelGridEdges, siteCoords) 
%% Construct the sampling matrix for the observations sites in the model grid.
%
% [H] = buildH( modelGridEdges, siteCoords) 
%
%
% ----- Inputs -----
%
% modelGridEdges: This is a cell vector containing the coordinates of the
%       edges of model grid cells for a single time instant. These
%       coordinates must be given in the order they occur in the model. 
%
%       For example, if a model time slice consists of a 3D grid that is
%       longitude x latitude x height, then modelIndices would be:
%       {lonIndices, latIndices, heightIndices}
%
%       The individual indices must be strictly monotonic and should list 
%       the coordinates on the EDGE of individual grid cells, rather than
%       the center. If a particular dimension is covered by N grid cells,
%       then the set of indices should have N+1 members (one for the second
%       edge of the last grid cell)
%
%       !!!!!!!!!
%       Later functionality should provide a toggle to flip between edge
%       and center coordinates
%
%       We could also do upper unbounded coordinates instead of strictly
%       grid edges. Although, I think the slight extra rigor in the current
%       setup could be useful for nonlinear H. 
%       !!!!!!!!!!
%
% siteCoords: A matrix containing the coordinates of each observation
%       site. Each row is one site, and each column is one dimension of the
%       model. The columns should be listed in the same order as the 
%       dimensions of the model grid. 
%
%       For a model time slice that is a 3D grid of lon x lat x height with
%       P observations, siteIndices would be:
%       [ lon1, lat1, height1;
%         lon2, lat2, height2;
%         ...    ...   ...
%         lonP, latP, heightP];
%
%       The coordinates should be listed in the same order that 
%       observations are provided for data assimilation.
%
% 
% ----- Outputs -----
%
% H: The sampling matrix for the observation sites in the model grid. This
%   is a logical matrix that is the number of observations x number of
%   variables in the state vector. Each row is all false except for one
%   index corresponding to a sample site. 
%
%
% ----- Written By -----
% Jonathan King, 2018
% University of Arizona
% jonking93@email.arizona.edu

% Do some error checking for the sets of indices. Also get the size of the
% model grid.
sGrid = setup( modelGridEdges, siteCoords );

% Get the index of each observation site on the model grid.
[siteDex] = getSiteIndex( modelGridEdges, siteCoords, sGrid); 
    
% Create the sampling matrix H
H = false( length(siteDex), prod(sGrid) );

% Add a site location to each row of H
for k = 1:length(siteDex)
    H(k, siteDex(k)) = true;
end

end

function[siteDex] = getSiteIndex( modelGridEdges, siteCoords, sGrid)

% Preallocate indices in the model grid for each site. Use a cell array to
% enable a later call to sub2ind for general matrix dimensionality.
sSites = size(siteCoords);
siteDex = NaN( sSites );

% For each site...
for j = 1:sSites(1)
    
    % Get the coordinates in each model grid dimension...
    for k = 1:sSites(2)
        
        % Find the grid boundaries that are less than the site coordinate.
        % Get the maximum of these values
        lessEdges = modelGridEdges{k} < siteCoords(j,k);
        nextEdge = max( modelGridEdges{k}(lessEdges) );   
        siteDex(j,k) = find( modelGridEdges{k} == nextEdge );
        % !!!!
        % The preceding block of code could be improved to script directly
        % to a logical.
    end
end

% Check that there are no overlapping observation sites by ensuring that
% all rows are unique.
[~, uRow] = unique( siteDex, 'rows');

% If overlap does exist, throw error and report which values overlap / are duplicates
if length(uRow) ~= sSites(1)
    overlap = find( ~ismember( 1:sSites(1), uRow ), 1);
    overlap = find( ismember( siteDex, siteDex(overlap,:), 'rows') );
    overlap = [ num2str(overlap(1:end-1)'), ' and ', num2str(overlap(end)) ];
    
    error('Multiple observation sites overlap on the same model grid cell.\nObservation sites %s are overlapping',overlap);
end

% Convert siteDex to cell array to enable call to sub2ind for matrices of
% general dimensionality
cellDex = num2cell( siteDex );

% Get linear index of each site (the index in the state vector)
siteDex = NaN( sSites(1), 1);
for k = 1:sSites(1)
    siteDex(k) = sub2ind( sGrid, cellDex{k,:} );
end

end

function[sGrid] = setup(modelGridEdges, siteCoords)
%% This computes some sizes and error checking.

% Check that modelIndices is a cell vector
if ~iscell(modelGridEdges) || ~isvector(modelGridEdges)
    error('modelIndices must be a cell vector');
end

% Preallocate the size of the model grid
nDims = length(modelGridEdges);
sGrid = NaN( 1, nDims );

% For each set of model indices...
for k = 1:nDims
    
    % Check that the indices are a vector
    if ~isvector(modelGridEdges{k})
        error('All sets of model indices must be vectors. Set %0.f is not a vector.', k);
    
    % Also ensure monotonic
    elseif ~issorted( modelGridEdges{k}, 'strictmonotonic')
        error('All model indices must be strictly monotonic. Set %0.f is not monotonic.',k);
    end
    
    % Record the dimension size
    sGrid(k) = length( modelGridEdges{k} ) - 1;
    
    % Ensure that this was a non-singleton dimension
    if sGrid(k) < 1
        error('All model indices must contain at least 2 elements. Set %.f has fewer than 2 elements');
    end
end

% Check that siteIndices is a matrix with nDims columns and no missing
% values
if ~ismatrix(siteCoords) || size(siteCoords,2)~=nDims || any( isnan(siteCoords(:)) )
    error('siteIndices must be a 2D matrix with one column for each dimension in the model grid.');
elseif any( isnan(siteCoords(:)) )
    error('siteIndces may not contain missing values.');
end

% Check that all site coordinates are within the bounds of the model grid
% !!!!!!! Should convert this to a single matrix operation
for k = 1:nDims
    if any( siteCoords(:,k)>max(modelGridEdges{k}) | ...
            siteCoords(:,k)<min(modelGridEdges{k}) )
        error('Site coordinates for dimension %.f are not within the model grid bounds',k);
    end
end

end
