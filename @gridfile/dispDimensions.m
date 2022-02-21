function[] = dispDimensions(metadata)
%% gridfile.dispDimensions  Print dimension sizes and metadata to the console
% ----------
%   gridfile.dispDimensions(metadata)
%   Prints dimension names, sizes, and (if possible) metadata limits for a 
%   gridMetadata object associated with a gridfile or gridfile data source.
% ----------
%   Inputs:
%       metadata (scalar gridMetadata object): The dimensional metadata
%           associated with a component of a gridfile dataset.
%
%   Outputs:
%       Prints dimension names, sizes, and metadata limits to the console.
%
% <a href="matlab:dash.doc('gridfile.dispDimensions')">Documentation Page</a>

% Get dimensions and sizes
[dims, sizes] = metadata.defined;
nDims = numel(dims);
sizes = string(sizes);

% Get metadata limits
metaLimits = strings(nDims,2);
for d = 1:nDims
    dim = dims(d);
    meta = metadata.(dim);
    if size(meta,2)==1
        metaLimits(d,1) = string(meta(1));
        metaLimits(d,2) = string(meta(end));
    end
end

% Get field lengths
nameLength = max(strlength(dims));
sizeLength = max(strlength(sizes));
meta1Length = max(strlength(metaLimits(:,1)));
meta2Length = max(strlength(metaLimits(:,2)));

% Get line formats
nometa = sprintf('        %%%.fs: %%%.fs\n', nameLength, sizeLength);
withmeta = sprintf('%s    (%%%.fs to %%-%.fs)\n', nometa(1:end-1), meta1Length, meta2Length);

% Print dimension sizes and metadata
fprintf('    Dimension Sizes and Metadata:\n');
for d = 1:nDims
    if strcmp(metaLimits(d,1), "")
        fprintf(nometa, dims(d), sizes(d));
    else
        fprintf(withmeta, dims(d), sizes(d), metaLimits(d,1), metaLimits(d,2));
    end
end

% End block with newline
fprintf('\n');

end