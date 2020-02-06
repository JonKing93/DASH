function[] = getStateIndices( obj, ensMeta, sstName, sssName, monthName, varargin ) 
    % Concatenate the variable names
    varNames = [string(sstName), string(sssName)];
    % Get the time dimension
    [~,~,~,~,~,~,timeID] = getDimIDs;
    obj.H = ensMeta.closestLatLonIndices( obj.coord, varNames, timeID, monthName, varargin{:} );
end