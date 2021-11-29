function[indices] = indices(obj, sources, header)
%% dash.gridfileSources.indices  Parse the indices of data sources in the catalogue
% ----------
%   indices = <strong>obj.indices</strong>(sources, header)
%   Parse the indices of data sources in the catalogue. Error checks array
%   indices and locates source names. Returns linear indices to the
%   specified sources. Throws error if sources are an unrecognized input
%   type.
% ----------
%   Inputs:
%       sources: The input being parsed. Should either be array indices or
%           source names.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       indices (vector, linear indices): The indices of the specified data
%           sources in the catalogue.
%
% <a href="matlab:dash.doc('dash.gridfileSources.indices')">Documentation Page</a>

% Setup
if ~exist('header','var') || isempty(header)
    header = "DASH:gridfileSources:indices";
end
nSources = numel(obj.source);

% Error check direct indices
if isnumeric(sources) || islogical(sources)
    logicalLength = 'one element per data source';
    linearMax = 'the number of data sources';
    indices = dash.assert.indices(sources, nSources, 'sources', logicalLength, linearMax, header);
    
% File name input - start by getting absolute paths to sources
elseif dash.is.strlist(sources)
    inputSources = string(sources);
    sourcePaths = obj.absolutePaths;
    
    % Split source names from extensions
    sourceNames = cellstr(sourcePaths);
    sourceExt = cell(nSources, 1);
    for s = 1:nSources
        [path, name, ext] = fileparts(sourceNames{s});
        sourceNames{s} = ['/',path,'/',name];
        sourceExt{s} = ext;
    end
    
    % Preallocate indices, use char comparisons. 
    nInputs = numel(inputSources);
    indices = NaN(nInputs, 1);
    
    % Check each input for an extension.
    [~,~,ext] = fileparts(inputSources);
    for k = 1:nInputs
        hasExtension = ~strcmp(ext(k), "");
        
        % Clean input string and get char length
        input = char(inputSources(k));
        input = dash.file.urlSeparators(input);
        if input(1)~='/'
            input = strcat('/',input);
        end
        inputLength = length(input);
        
        % Get the source path (with or without extension) for comparison
        for s = 1:nSources
            comparePath = sourceNames{s};
            if hasExtension
                comparePath = [comparePath, sourceExt{s}]; %#ok<AGROW>
            end
            
            % Check for a match.
            match = false;
            if length(comparePath)>=inputLength &&...
                    strcmp(comparePath(end-inputLength+1:end), input)
                match = true;
            end
            
            % Record matching source, but don't allow multiple matches
            if match && isnan(indices(k))
                indices(k) = s;
            elseif match
                multipleMatchesError(k, input, indices(k), s, obj.gridfile, header);
            end
        end
        
        % Throw error if there are no matches
        if isnan(indices(k))
            noMatchingSourcesError(k, input, obj.gridfile, header);
        end
    end
    
% Any other type of input
else
    id = sprintf('%s:invalidDataSource', header);
    error(id, ['sources must either be a vector of data source indices, or ',...
        'a list of data source names.']);
end

end

% Long error messages

function[] = multipleMatchesError(k, input, existingIndex, newIndex, gridFile, header)
id = sprintf('%s:multipleMatchingSources', header);
error(id, ['Input data source %.f ("%s") matches multiple data sources (sources %.f and %.f) ',...
    'in the gridfile. Either use data source indices to select sources, or ',...
    'add more file path information to input %.f.\n\ngridfile: %s'],...
    k, input(2:end), existingIndex, newIndex, k, gridFile);
end
function[] = noMatchingSourcesError(k, input, gridFile, header)
id = sprintf('%s:noMatchingSources', header);
error(id, 'No data sources match input data source %.f ("%s").\n\ngridfile: %s', ...
    k, input(2:end), gridFile);
end