function[schema] = buildGridSchema( gridData, dimID, meta )
% Create the netcdf4 schema for a new .grid file

% Writing a netcdf4 file
schema = struct();
schema.Name = '/';
schema.Format = 'netcdf4';

% Get a marker for extended metadata elements
nDim = numel(dimID);
k = nDim+1;
gridSize = fullSize(gridData, nDim);

% Dimensions
for d = 1:nDim
    
    % Specific dimension
    schema.Dimensions(d).Name = char( dimID(d) );
    schema.Dimensions(d).Length = gridSize(d);
    schema.Dimensions(d).Unlimited = true;
    
    % Optional metadata dimension
    dimRef = [];
    nMetaEls = size( meta.(dimID(d)), 2 );
    if nMetaEls > 1
        schema.Dimensions(k).Name = char( strcat( dimID(d), 'Metadata' ) );
        schema.Dimensions(k).Length = nMetaEls;
        schema.Dimensions(k).Unlimited = false;
        dimRef = k;
        k = k+1;
    end
    
    % Dimensional metadata
    schema.Variables(d).Name = char( dimID(d) );
    schema.Variables(d).Dimensions = schema.Dimensions([d, dimRef]);
    schema.Variables(d).Datatype = class( meta.(dimID(d)) );
    schema.Variables(d).FillValue = NaN;
end



% % The gridded data
% d = d + 1;
% schema.Variables(d).Name = 'gridData';
% schema.Variables(d).Dimensions = schema.Dimensions(1:nDim);
% schema.Variables(d).Datatype = class( gridData );
% 
% % The variable attributes
% [~, specs] = getDimIDs;
% attNames = string( fieldnames( meta.(specs) ) );
% nAtt = numel(attNames);
% 
% for a = 1:nAtt
%     schema.Variables(d).Attributes(a).Name = char( attNames(a) );
%     schema.Variables(d).Attributes(a).Value = meta.(specs).(attNames(a));
% end

end