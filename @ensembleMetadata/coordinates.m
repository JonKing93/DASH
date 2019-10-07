function[coord] = coordinates( obj )
% Gets point lat-lon coordinates for the entire ensemble.
%
% coord = obj.coordinates
%
% *** Returns NaN coordinates for spatial means and variables lacking
% lat-lon coordinate information.
%
% ----- Outputs -----
%
% coord: Lat-lon coordinates of each state vector element. (nState x 2)

% Preallocate
coord = NaN( obj.varLimit(end), 2 );

% Try to extract coordinates from each variable. Just leave as NaN if it
% fails, or if they are spatial means.
for v = 1:numel(obj.varName)
    try
        latlon = obj.getLatLonMetadata( obj.varName(v) );
    catch
    end
    if ismatrix(latlon)
        coord( obj.varIndices(obj.varName(v)), : ) = latlon;
    end
end

end