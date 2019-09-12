classdef ensemble < handle
% ensemble
% Builds and loads ensembles.
%
% ensemble Properties:
%   ...
%
% ensemble Methods:
%   ...
%

properties (SetAccess = private)
    design;            % The state design associated with the ensemble
    file;              % The .ens file associated with the ensemble
    
    % Used to add
    random;            % Whether the ensemble is ordered or random
    unsaved;           % Whether the ensemble has unsaved changes not written to file
                       
    members;           % Which ensemble members to load
    canOverwrite;         % Whether to overwrite existing .ens files when writing to file.
    hasnan;            % Indicates which ensemble members contain NaN.
    writenan;          % Whether or not to write ensemble members
                       % containing NaN to file. (Default is false)
                       
    haschanges;        % Whether the ensemble has been altered?                       
end

% Constructor. Creates an ensemble object from a .ens file.
methods
    function obj = ensemble( source, overwrite )
        % Creates a new ensemble object.
        %
        % obj = ensemble( source )
        % Creates an ensemble object using either a state design object or
        % an existing .ens file as the source.
        %
        % obj = ensemble( source, overwrite )
        % Specify whether the ensemble object can overwrite existing files
        % when writing to file. Default is false.
        %
        % ----- Inputs -----
        %
        % source: The source of the ensemble object. Either a state design
        %         object (for ensembles not written to file), or a .ens
        %         filename (for previously saved ensembles).
        %
        % overwrite: A scalar logical indicating whether the ensemble
        %            object can overwrite existing files.
        %
        % ----- Outputs -----
        %
        % obj: A new ensemble object.
        
        % Check that the source is either a state design, or a .ens file.
        % Error check accordingly.
        if isa(source, 'stateDesign') 
            source.review;
        elseif isstrflag(source)
            checkFile( source, 'extension', '.ens', 'exist', true );
        else
            error('source must either be a "stateDesign" object, or a filename (string or character row vector).');
        end
        
        % Get default overwrite if unspecified. Error check user inputs
        if ~exist('overwrite','var') || isempty(overwrite)
            overwrite = false;
        elseif ~isscalar(overwrite) || ~islogical(overwrite)
            error('overwrite must be a scalar logical.');
        end
        
        % Set values
        obj.source = source;
        obj.overwrite = overwrite;
    end    
end


methods
    
    % Adds additional ensemble members to an ensemble.
    add( obj, nEns );
    
    % Writes an ensemble to a .ens file. 
    write( obj, file );
    
    % Specifies whether overwriting .ens files is allowed
    overwrite( obj, tf );
    
    % Returns the ensemble as output. If obj.source is a stateDesign,
    % builds the ensemble from scratch. If obj.source is a .ens file, loads
    % from file. If the ensemble has unwritten changes, loads what is
    % possible from file, and builds the rest.
    load;
    

    
    % Specifies which ensemble members to load.
    useMembers;
end


% Internal utilities
methods (Access = private)
    
    % Builds an ensemble from a state design.
    build;

    % Loads the ensemble from a file
    loadFromFile;

end
