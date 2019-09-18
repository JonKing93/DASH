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

    % Used / Set when writing
    canOverwrite;      % Whether to overwrite existing .ens files when writing to file.
    hasnan;            % Whether an ensemble member has NaN values
    ensSize;           % The size of the full ensemble
    
    % Used to add
    random;            % Whether the ensemble is ordered or random
end

% Constructor
methods
    function obj = ensemble( design, random )
        % Creates a new ensemble object from a .ens file
        %
        % obj = ensemble( file )
        % Returns the ensemble object for a .ens file.
        %
        % ----- Inputs -----
        %
        % design: A state design with draws
        %
        % random: Whether the draws are random or ordered. A scalar logical
        %
        % ----- Outputs -----
        %
        % obj: A new ensemble object

        % Error check
        if ~isa(design,'stateDesign')
            error('design must be a stateDesign.');
        elseif ~isscalar( design )
            error('design must be a scalar stateDesign object.');
        elseif design.new
            error('The state design has no ensemble members. Please use the "stateDesign.buildEnsemble" function.');
        elseif ~isscalar(random) || ~islogical(random)
            error('random must be a scalar logical.');
        end

        % Set values
        obj.design = design;
        obj.random = random;
        obj.canOverwrite = false;

        % Determine the ensemble size
        varLimits = design.varIndices;
        nState = varLimits(end);
        
        ensDim1 = find( ~design.var(1).isState, 1 );
        nEns = numel( design.var(1).drawDex{ensDim1} );
        
        obj.ensSize = [nState, nEns];
    end
end

% User methods
methods
    % Adds additional ensemble members to an ensemble.
    obj = add( obj, nAdd );

    % Writes an ensemble to a .ens file.
    write( obj );

    % Loads and ensemble from a .ens file and returns it as output.
    % *** In the future this could be made fancier. E.g. only load
    % non-Nans, or specific ensemble members.
    M = load( obj );

    % Allows the object to overwrite preexisting files
    overwrite( obj, tf );
end

end