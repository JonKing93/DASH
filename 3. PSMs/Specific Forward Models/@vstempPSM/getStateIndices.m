function[] = getStateIndices( obj, ensMeta, Tname, monthMeta, varargin )
% Gets state indices for a vstempPSM
%
% obj.getStateIndices( ensMeta, Tname, monthMeta )
% Finds the closest temperature element in the specified months.
%
% obj.getStateIndices( ..., dimN, metaN )
% Specifies additional search parameters. See PSM.getClosestLatLonIndex for
% details.
%
% ----- Inputs -----
%
% ensMeta: An ensemble metadata object
%
% Tname: The name of the temperature variable
%
% monthMeta: Metadata for the required months. Each row is one month.

% Get the closest indices
[~,~,~,~,~,~,time] = getDimIDs;
            
obj.H = ensMeta.closestLatLonIndices( [obj.lat, obj.lon], Tname, time, ...
                                        monthMeta, varargin{:} );
                         
end