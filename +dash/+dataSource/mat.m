classdef mat < dash.dataSource.hdf
    %% dash.dataSource.mat  Objects that read data from MAT-files
    % ----------
    % mat Methods:
    %
    % General:
    %   mat           - Create a new dash.dataSource.mat object
    %   loadStrided   - Load data from a MAT-file at strided indices
    %
    % Disable Warnings:
    %   v73warning    - Issue informative warning if the .mat file for a dataSource is not version 7.3
    %
    % Inherited:
    %   load          - Load data from a HDF5 source
    %   setVariable   - Ensure variable exists in MAT-file
    %
    % <a href="matlab:dash.doc('dash.dataSource.mat')">Documentation Page</a>

    properties (SetAccess = private)
        m;  % A matfile object used to load data
    end
    properties (Constant)
        warnID = "MATLAB:MatFile:OlderFormat";   % ID of the disabled v7.3 warning message
    end
    
    methods
        function[obj] = mat(file, var)
        %% dash.dataSource.mat.mat  Create a new dash.dataSource.mat object
        % ----------
        %   obj = <strong>dash.dataSource.mat</strong>(file, var)
        %   Creates a mat object to read data from a variable in a MAT-file
        % ----------
        %   Inputs:
        %       file (string scalar): The name of a MAT-file
        %       var (string scalar): The name of the variable to load from
        %           the file. The variable in the file must not be empty.
        %
        %   Outputs:
        %       obj (scalar dash.dataSource.mat object): The new mat object
        %
        %   Throws:
        %       DASH:dataSource:mat:invalidMatfile  if file is not a valid .mat file
        %
        % <a href="matlab:dash.doc('dash.dataSource.mat.mat')">Documentation Page</a>
            
        % Error check
        header = 'DASH:dataSource:mat';
        dash.assert.strflag(var, 'var', header);
        dash.assert.strflag(file, 'file', header);
        obj.source = dash.assert.fileExists(file, ".mat", header);

        % Check the file is a valid matfile
        try
            obj.m = matfile(obj.source);
        catch
            id = sprintf('%s:invalidMatfile', header);
            error(id, ['The file:\n\t%s\n',...
                       'is not a valid MAT-file'], obj.source);
        end
        
        % Check the variable is valid, get data type and size
        info = whos(obj.m, var);
        if isempty(info)
            name = '';
        else
            name = info.name;
        end
        
        obj = obj.setVariable(char(var), name);        
        obj.dataType = info.class;
        obj.size = info.size;

        % Do not allow empty variables
        if ismember(0, obj.size)
            error('DASH:dataSource:mat:emptyArray', ...
                ['Variable "%s" is empty.\n',...
                'Data source file: %s'], obj.var, obj.source);
        end

        % Warn user if not v7.3 MAT-file. Convert the warning message
        % to error so it is catchable, then give descriptive message.
        reset = dash.warning.state('error', obj.warnID); %#ok<NASGU> 
        firstIndex = repmat({1}, [1, numel(obj.size)]);
        try
            obj.m.(obj.var)(firstIndex{:});
        catch ME
            if strcmp(ME.identifier, obj.warnID)
                obj.v73warning;
            else
                rethrow(ME);
            end
        end
        
        end
        function[X] = loadStrided(obj, indices)
        %% dash.dataSource.mat.loadStrided  Load data from a MAT-file at strided indices
        % ----------
        %   X = <strong>obj.loadStrided</strong>(stridedIndices)
        %   Load data from the variable in the MAT-file at the specified strided indices.
        % ----------
        %   Inputs:
        %       stridedIndices (cell vector [nDims] {vector, strided linear indices}):
        %           The indices of data elements along each dimension to load from 
        %           the MAT-file. Should have one element per dimension of the variable.
        %           Each element holds a vector of strided linear indices.
        % 
        %   Outputs:
        %       X (array): The loaded data
        %
        % <a href="matlab:dash.doc('dash.dataSource.mat.loadStrided')">Documentation Page</a>
        
        % Disable the partial load warning (it will reset state by default)
        reset = dash.warning.state('off', obj.warnID); %#ok<NASGU> 
        
        % Adjust the indices to include a second dimension if the variable
        % is a column vector
        if numel(indices)==1
            indices = [indices, {1}];
        end
        
        % Load
        X = obj.m.(obj.var)(indices{:});
        
        end
        function[] = v73warning(obj)
        %% dash.dataSource.mat.v73warning  Issue informative warning if the .mat file for a dataSource is not version 7.3
        % ----------
        %   <strong>obj.v73warning</strong>
        %   Issue an informative warning when the MAT-file for the object
        %   is not version 7.3.
        % ----------
        %   Warnings:
        %       Prints a warning to the console if the MAT-file is not v7.3
        %
        % <a href="matlab:dash.doc('dash.dataSource.mat.v73warning')">Documentation Page</a>
        
        [~,name,ext] = fileparts(obj.source);
        file = strcat(name, ext);
        saveLink = "matlab:web(fullfile(docroot, 'matlab/ref/save.html#btox10b-1-version'))";
        versionsLink = "matlab:web(fullfile(docroot, 'matlab/import_export/mat-file-versions.html'))";
        
        warning("DASH:dataSource:mat:matfileNotV73",...
            ['File "%s" is not a version 7.3 MAT-file. Version 7.3 files are recommended ',...
            'for use with DASH. You may want to re-save "%s" using the ''-v7.3'' ',...
            'flag. See the Matlab documentation on <a href="%s">save</a> ',...
            'and <a href="%s">MAT-File versions</a> for more information.'],...
            file, file, saveLink, versionsLink);
        
        end
    end
    
end