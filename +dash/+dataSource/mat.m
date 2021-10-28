classdef mat < dash.dataSource.hdf
    %% dash.dataSource.mat  Objects that read data from .mat files
    % ----------
    % mat Methods:
    %
    % General:
    %   mat           - Create
    %   loadStrided   - load in intervals
    %
    % v73 Matfile Warnings:
    %   toggleWarning - Change warning state
    %   v73warning    - Informative
    %
    % Inherited:
    %   load          -  Load from HDF5 source
    %   setVariable   - Set the name of the variable in the HDF5 source
    %
    % <a href="matlab:dash.doc('dash.dataSource.mat')">Documentation Page</a>

    
    %
    %
    % 
    %   
    %
    %   <strong>General dataSource operations</strong>
    %   mat Properties:
    %                m - The matfile object used to load data
    %
    %   mat Methods:
    %              mat - Create a new dash.dataSource.mat object
    %      loadStrided - Load data from a .MAT file at strided linear indices
    %
    %   <strong>Manipulate MAT-file warnings</strong>
    %   mat Properites:
    %            warnID - (Constant) ID of a v7.3 warning message to disable
    %
    %   mat Methods:
    %        v73warning - Descriptive warning when not using v7.3 .mat files
    %     toggleWarning - Toggle state of warning for old format .mat files
    %
    %
    %   <a href="matlab:dash.doc('dash.dataSource.mat')">Online Documentation</a>
    
    properties (SetAccess = private)
        m;  % A matfile object used to load data
    end
    properties (Constant)
        warnID = "MATLAB:MatFile:OlderFormat";   % ID of the disabled v7.3 warning message
    end
    
    % General dataSource methods
    methods
        function[obj] = mat(file, var)
        %% dash.dataSource.mat.mat  Create a new dash.dataSource.mat object
        % ----------
        %   obj = dash.dataSource.mat(file, var)
        %   Creates a mat object to read data from a variable in a MAT-file
        % ----------
        %   Inputs:
        %       file (string scalar): The name of a MAT-file
        %       var (string scalar): The name of the variable to load from the file
        %
        %   Outputs:
        %       obj: A new dash.dataSource.mat object
        %
        %   Throws:
        %       DASH:dataSource:mat:invalidMatfile  if file is not a valid .mat file
        %
        %   <a href="matlab:dash.doc('dash.dataSource.mat.mat')">Online Documentation</a>
            
        % Error check
        header = 'DASH:dataSource:mat';
        dash.assert.strflag(var, 'var', header);
        dash.assert.strflag(file, 'file', header);
        obj.source = dash.assert.fileExists(file, ".mat", header);

        % Check the file is a valid matfile
        try
            obj.m = matfile(obj.source);
        catch problem
            ME = MException(sprintf('%s:invalidMatfile',header), ...
                'The file "%s" is not a valid .mat file', obj.source);
            ME = addCause(ME, problem);
            throw(ME);
        end

        % Check the variable is valid
        fileVars = string(who(obj.m));
        obj = obj.setVariable(char(var), fileVars);

        % Get data type and size
        info = whos(obj.m, var);
        obj.dataType = info.class;
        obj.size = info.size;

        % Warn user if not v7.3 MAT-file. Convert the warning message
        % to error so it is catchable, then give descriptive message.
        obj.toggleWarning('error');       
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
        %% dash.dataSource.mat.loadStrided  Load data from a MAT-file source
        % ----------
        %   X = obj.loadStrided(stridedIndices)
        %   Load data from the variable in the MAT-file at the specified strided indices.
        % ----------
        %   Inputs:
        %       stridedIndices (vector, strided linear indices): The indices of
        %           data elements to load from the MAT-file
        % 
        %   Outputs:
        %       X (array): The loaded data
        %
        %   <a href="matlab:dash.doc('dash.dataSource.mat.loadStrided')">Online Documentation</a>
        
        % Disable the partial load warning, then load
        obj.toggleWarning('off');
        X = obj.m.(obj.var)(indices{:});
        
        end
    end
    
    % Warning manipulation methods
    methods
        function[reset] = toggleWarning(obj, state)
        %% dash.dataSource.mat.toggleWarning  Change the state of the v7.3 matfile warning.
        % ----------
        %   reset = obj.toggleWarning(state)  toggles the state of the
        %   Old-Format Mat-File warning to a specified state and returns a
        %   cleanup object that will reset the warning to its initial state
        %   when the object is destroyed.
        % ----------
        %   Inputs:
        %       state ('on'|'off'|'error'): Desired state of the warning.
        %
        %   Outputs:
        %       reset (onCleanup object): An object that resets the initial state
        %           of warning when destroyed
        %
        %   <a href="matlab:dash.doc('dash.dataSource.mat.toggleWarning')">Online Documentation</a>
        
        warn = warning('query', obj.warnID);
        warning(state, obj.warnID);
        reset = onCleanup(  @()warning(warn.state, obj.warnID)  );
        
        end
        function[] = v73warning(obj)
        %% dash.dataSource.mat.v73warning  Issue warning if the .mat file for a dataSource is not version 7.3
        % ----------
        %   dash.dataSource.mat.v73warning issues a warning that the .mat file for
        %   the dataSource.mat object is not version 7.3
        % ----------
        %   Outputs:
        %       Prints a warning to the console
        %
        %   <a href="matlab:dash.doc('dash.dataSource.mat.v73warning')>Online Documentation</a>
        
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