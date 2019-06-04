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
    schema.Dimensions(d*2-1).Name = char( dimID(d) );
    schema.Dimensions(d*2-1).Length = gridSize(d);
    schema.Dimensions(d*2-1).Unlimited = true;
    
    % Metadata columns dimension
    schema.Dimensions(d*2).Name = char( strcat( dimID(d), 'MetaCols' ) );
    schema.Dimensions(d*2).Length = size( meta.(dimID(d)), 2 );
    schema.Dimensions(d*2).Unlimited = true;
    
%     % Dimensional metadata
%     schema.Variables(d).Name = char( dimID(d) );
%     schema.Variables(d).Dimensions = schema.Dimensions([d, dimRef]);
%     schema.Variables(d).Datatype = class( meta.(dimID(d)) );
end

%% This syntax appears to cause a bug in ncwrite...

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