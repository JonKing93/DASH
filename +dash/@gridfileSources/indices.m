function[indices] = indices(obj, sources, gridFile, header)
%% Return the indices of data sources

% Setup
if ~exist('header','var') || isempty(header)
    header = "DASH:gridfileSources:indices";
end
nSources = numel(obj.source);

% Error check direct indices
if isnumeric(sources) || islogical(sources)
    logicalLength = 'one element per data source';
    linearMax = 'number of data sources';
    indices = dash.assert.indices(sources, nSources, 'sources', logicalLength, linearMax, header);
    
% File name input
elseif dash.is.strlist(sources)
    inputSources = string(sources);
    inputSources = dash.file.urlSeparators(inputSources);
    sourcePaths = obj.source;
    gridPath = fileparts(gridFile);
    
    % Get absolute path to all files
    rel = obj.relativePath;
    if any(rel)
        absPaths = strcat(gridPath, '/', sourcePaths(rel));
        for s = 1:numel(absPaths)
            absPaths(s) = dash.file.collapsePath(absPaths(s));
        end
        sourcePaths(rel) = absPaths;
    end
    
    % Split source names from extensions
    sourceNames = cellstr(sourcePaths);
    sourceExt = cell(nSources, 1);
    for s = 1:nSources
        [path, name, ext] = fileparts(sourceNames{s});
        sourceNames{s} = [path,'/',name];
        sourceExt{s} = ext;
    end
    
    % Preallocate indices, use char comparisons
    nInputs = numel(inputSources);
    indices = NaN(nInputs, 1);
    inputSources = cellstr(inputSources);
    
    % Check each input for an extension. Get total input length
    [~,~,ext] = fileparts(inputSources);
    for k = 1:nInputs
        hasExtension = ~isempty(ext{k});
        inputLength = length(inputSources{k});
        
        % Get the source path (with or without extension) for comparison
        for s = 1:nSources
            comparePath = sourceNames{s};
            if hasExtension
                comparePath = [comparePath, sourceExt{s}]; %#ok<AGROW>
            end
            
            % Check for a match.
            match = false;
            if length(comparePath)>=inputLength &&...
                    strcmp(comparePath(end-inputLength+1:end), inputSources{k})
                match = true;
            end
            
            % Record matching source, but don't allow multiple matches
            if match && isnan(indices(k))
                indices(k) = s;
            elseif match
                multipleMatchesError(k, inputSources{k}, indices(k), s, gridFile, header);
            end
        end
        
        % Throw error if there are no matches
        if isnan(indices(k))
            noMatchingSourcesError(k, inputSources{k}, gridFile, header);
        end
    end
    
% Any other type of input
else
    id = sprintf('%s:invalidDataSource', header);
    error(id, ['sources must either be a vector of data source indices, or ',...
        'a list of data source names.']);
end

end