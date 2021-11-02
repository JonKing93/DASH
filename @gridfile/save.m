function[] = save(obj)
%% gridfile.save  Save a gridfile object to a .grid file
% ----------
%   <strong>obj.save</strong>
%   Saves the contents of the current gridfile object to its associated
%   .grid file.
% ----------
%
% <a href="matlab:dash.doc('gridfile.save')">Documentation Page</a>

% Get the values
meta = obj.meta;
dims = obj.dims;
sizes = obj.sizes;

fill = obj.fill;
range = obj.range;
transform = obj.transform;
transform_type = obj.transform_type;
transform_params = obj.transform_params;

source = obj.source;
relativePath = obj.relativePath;
dimLimit = obj.dimLimit;

source_fill = obj.source_fill;
source_range = obj.source_range;
source_transform = obj.source_transform;
source_transform_type = obj.source_transform_type;
source_transform_params = obj.source_transform_params;

% Save to file
save(obj.file, '-mat',...
    'meta', 'dims', 'sizes',...
    'fill','range','transform','transform_type','transform_params',...
    'source', 'relativePath', 'dimLimit',...
    'source_fill','source_range',...
    'source_transform','source_transform_type','source_transform_params'...
    );

end