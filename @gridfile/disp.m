function[] = disp(obj)
%% gridfile.disp  Display gridfile object in console
% ----------
%   <strong>obj.disp</strong>
%   Displays the contents of a gridfile object to the console. Prints .grid
%   file name, dimensions, dimension sizes, and the limits of dimensional
%   metadata. Prints metadata attributes if they exist. Prints a summary of
%   data sources.
% ----------
%
% <a href="matlab:dash.doc('gridfile.disp')">Documentation Page</a>

% Get the class documentation link
link = '<a href="matlab:dash.doc(''gridfile'')">gridfile</a>';

if ~obj.isvalid
    fprintf('  deleted %s array\n\n', link);
    return;
end

% If not scalar, display array size and exit
if ~isscalar(obj)
    info = dash.string.nonscalarObj(obj, link);
    fprintf(info);
    return
end

% Link header
fprintf('  %s with properties:\n\n', link);

% File and dimensions list
fileIndent = '';
dimsList = '';
if ~isempty(obj.dims)
    fileIndent = '      ';
    dims = sprintf('%s, ', obj.dims);
    dims(end-1:end) = [];
    dimsList = sprintf('Dimensions: %s\n', dims);
end
fprintf('    %sfile: %s\n', fileIndent, obj.file);
fprintf('    %s\n', dimsList);

% Dimension sizes
if ~isempty(obj.dims)
    dims = obj.dims;
    sizes = string(obj.size);
    
    % Get metadata limits
    metaLimits = strings(numel(dims), 2);
    for d = 1:numel(dims)
        dim = dims(d);
        meta = obj.meta.(dim);
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
    
    % Print message
    fprintf('    Dimension Sizes:\n');
    for d = 1:numel(dims)
        if strcmp(metaLimits(d,1), "")
            fprintf(nometa, dims(d), sizes(d));
        else
            fprintf(withmeta, dims(d), sizes(d), metaLimits(d,1), metaLimits(d,2));
        end
    end
    fprintf('\n');
end

% Metadata attributes
[~, atts] = obj.meta.dimensions;
attributes = obj.meta.(atts);
fields = fieldnames(attributes);
if numel(fields)>0
    fields = string(fields);
    maxLength = max(strlength(fields));
    fprintf('    Attributes:\n\n');
    for f = 1:numel(fields)
        fieldLength = strlength(fields(f));
        pad = repmat(' ', 1, maxLength-fieldLength);
        fprintf('\b    %s', pad);
        atts = struct(fields(f), attributes.(fields(f)));
        disp(atts);
    end
end

% Data sources
if obj.nSource>0
    fprintf('    Data Sources: %.f\n\n', obj.nSource);
    listLink = sprintf('<a href="matlab:%s.dispSources">data sources</a>', inputname(1));
    fprintf('  Show %s\n\n', listLink);
end

end         