classdef ensemble < handle
% ensemble
% Builds and loads ensembles.
%
% ensemble Properties:
%   file - The .ens file associated with the ensemble.
%   writenan - Whether NaN values are permitted to write to file. 
%              (Currently only supports true)
%   hasnan - Whether each ensemble member contains NaN values.
%   ensSize - The size of the ensemble
%   random - Whether the ensemble members are random or ordered
%   design - The stateDesign associated with the ensemble.
%
% ensemble Methods:
%   load - Loads desired ensemble members.
%   add - Adds additional ensemble members to the stateDesign.
%   useVars - Only load specific variables
%   useVarsForPSMs - Only load the elements of specified variables needed
%                    to run PSMs
%   useMembers - Only load specific ensemble members
properties (SetAccess = private)
    file;              % The .ens file associated with the ensemble
    metadata;          % Ensemble metadata

    % Values also in the .ens file
    writenan;          % Whether NaN values have been written to file.
    hasnan;            % Whether a variable in an ensemble member has NaN values
    ensSize;           % The size of saved ensemble
    loadSize;          % The size of the loaded ensemble
    random;            % Whether the ensemble is ordered or random
    design;            % The state design associated with the ensemble
    
    % Load specifications
    loadMembers;       % Which ensemble members to load
    loadH;                 % Which state indices to load
end

% Constructor
methods
    function obj = ensemble( file )
        % Creates a new ensemble object from a .ens file
        %
        % obj = ensemble( file )
        % Returns the ensemble object for a .ens file.
        %
        % ----- Inputs -----
        %
        % file: A .ens file with a saved ensemble.
        %
        % ----- Outputs -----
        %
        % obj: A new ensemble object

        % Check that the file exists.
        checkFile( file, 'extension', '.ens', 'exist', true );
        obj.file = string( which( file ) );
        
        % Load the fields
        try
            required = {'random','ensSize','hasnan','writenan','design','complete'};
            m = load( file, '-mat', required{:} );
        catch
            error('The ensemble file may be corrupted.');
        end
            
        % Check for failed write or missing fields
        if ~isfield(m, 'complete') || ~isscalar(m.complete) || ~islogical(m.complete) || ~m.complete
            error('The file %s is not valid. It may have failed during a write operation.', file );
        end
        fileFields = fields(m);
        if any( ~ismember(fileFields, required) )
            error('File %s does not contain all required fields. It may be corrupted.');
        end
        
        % Set the properties
        obj.random = m.random;
        obj.ensSize = m.ensSize;
        obj.loadSize = m.ensSize;
        obj.hasnan = m.hasnan;
        obj.writenan = m.writenan;
        obj.design = m.design;
        
        % Create ensemble metadata
        obj.metadata = ensembleMetadata( m.design );

        % By default, load everything
        obj.loadMembers = 1:obj.ensSize(2);
        obj.loadH = [];
    end
end

% User methods
methods

    % Adds additional ensemble members to an ensemble.
    add( obj, nAdd );

    % Loads an ensemble from a .ens file
    [M, meta] = load( obj );
        
    % Specifies which ensemble members to load
    useMembers( obj, members );
    
    % Specifies which variables to load
    useVars( obj, vars );
    
    % Specifies to only load elements required for PSMs for specified
    % variables
    useVarsForPSMs( obj, vars, F );
    
    % Reset the ensemble to loading everything
    reset( obj );
end

% To be removed
methods
    meta = loadMetadata( obj );
end

% Internal utilities
methods

    % Checks a .ens file exists and is not corrupted. Returns a matfile
    ens = checkEnsFile( ~, file );
end

end