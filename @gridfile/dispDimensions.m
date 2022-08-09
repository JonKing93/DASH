function[] = dispDimensions(obj, s)
%% gridfile.dispDimensions  Print dimension sizes and metadata to the console
% ----------
%   <strong>obj.dispDimensions</strong>
%   <strong>obj.dispDimensions</strong>(0)
%   Prints dimension names, sizes, and (when possible) metadata limits for
%   a gridfile.
%
%   <strong>obj.dispDimensions</strong>(s)
%   Prints dimension names, sizes, and (when possible) metadata limits for
%   a data source catalogued in a gridfile.
% ----------
%   Inputs:
%       s (scalar integer): The index of a data source in the gridfile or 0.
%           If 0, prints dimension information for the full gridfile. If an
%           index, print dimension information for the corresponding data source.
%
%   Prints:
%       Prints dimension names, sizes, and metadata limits to the console.
%
% <a href="matlab:dash.doc('gridfile.dispDimensions')">Documentation Page</a>

% Get the metadata
if ~exist('s','var')
    s = 0;
end
metadata = obj.metadata(s);

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