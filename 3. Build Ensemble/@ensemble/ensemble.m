classdef ensemble
% ensemble
% Builds and loads ensembles.
%
% ensemble Properties:
%   ...
%
% ensemble Methods:
%   ...
%

properties
    loadElements;      % Which state vector elements to load.
    loadMembers;       % Which ensemble members to load
    fileName;          % The name of the .ens file.
end

% Constructor. Creates an ensemble object from a .ens file.
methods
    function obj = ensemble( ensFile, indices )
        % Constructor for an ensemble object.
        %
        % obj = ensemble( ensFile )
        % Creates an ensemble object for data stored in a .ens file. Will load data
        % from all ensemble members.
        %
        % obj = ensemble( ensFile, indices )
        % Loads data from specific ensemble members.
        %
        % ----- Inputs -----
        %
        % ensFile: A .ens extension.
        %
        % indices: The ensemble members that should be loaded.
        %
        % ----- Outputs -----
        %
        % obj: An ensemble object.

        % Check that the file and indices are valid. Get a matfile object.
        % ...

        % Get default indices
        if ~exist('indices','var') || isempty(indices)
            indices = (1 : m.ensSize(2))';
        end

        % Store values
        obj.ensFile = ensFile;
        obj.loadIndex = 
    end
end




methods

    % Builds an ensemble
    build;

    % Adds additional data to an ensemble
    add;

    % Loads an ensemble from a file.
    load;

end




end
