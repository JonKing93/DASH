classdef gridfileSources
    %% Manages additional data source details for gridfiles
    
    properties
        
        % Data source fields
        source = strings(0,1);      % The file path or opendap url to each data source
        var = strings(0,1);         % Variable names for HDF sources
        importOptions = cell(0,1);  % Import options for delimited text sources
        importOptionSource = [];     % The index of the source corresponding to each import option
        
        % Gridfile dimensions
        dims = strings(0,1);        % The data dimensions in each source
        size = strings(0,1);        % The size of each dimension
        mergedDims = strings(0,1);  % The data dimensions after merging
        mergedSize = strings(0,1);  % The size of each merged dimension
        
        % Data transformations
        fill = NaN(0,1);                % Fill value
        range = NaN(0,2);               % Valid range
        transform = strings(0,1);       % Transformation type
        transform_params = NaN(0,2);    % Transformation parameters
    end
    
    methods
        function[obj] = add(obj, dataSource, dims, size, mergedDims, mergedSize,...
                fill, range, transform, transform_params)
            
            % Data source fields
            obj.source = [obj.source; dataSource.source];
            varName = "";
            if isa(dataSource, 'dash.dataSource.hdf')
                varName = dataSource.var;
            end
            obj.var = [obj.var; varName];
            
            % Import options are stored in a cell, which can severely slow
            % down gridfile saves. Use source indexing to only record
            % import options when necessary.
            if isa(dataSource, 'dash.dataSource.text') && ~isempty(dataSource.importOptions)
                obj.importOptions = [obj.importOptions; dataSource.importOptions];
                obj.importOptionSource = [obj.importOptionSource; numel(obj.source)];
            end
            
            % Gridfile dimensions
            dims = strjoin(dims, ',');
            size = strjoin(string(size), ',');
            mergedDims = strjoin(mergedDims, ',');
            mergedSize = strjoin(string(mergedSize), ',');
            
            obj.dims = [obj.dims; dims];
            obj.size = [obj.size; size];
            obj.mergedDims = [obj.mergedDims; mergedDims];
            obj.mergedSize = [obj.mergedSize; mergedSize];
            
            % Data transformations
            obj.fill = [obj.fill; fill];
            obj.range = [obj.range; range];
            obj.transform = [obj.transform; transform];
            obj.transform_params = [obj.transform_params; transform_params];
        end
        function[obj] = remove(obj, s)
            
            % Use linear indices
            if islogical(s)
                s = find(s);
            end
            
            % Remove indexed import options
            remove = find(ismember(obj.importOptionSource, s));
            obj.importOptions(remove) = [];
            obj.importOptionSource(remove) = [];
            
            % Remove everything else
            obj.source(s) = [];
            obj.var(s) = [];
            obj.dims(s) = [];
            obj.size(s) = [];
            obj.mergedDims(s) = [];
            obj.mergedSize(s) = [];
            obj.fill(s) = [];
            obj.range(s,:) = [];
            obj.transform(s) = [];
            obj.transform_params(s,:) = [];
        end
    end
end