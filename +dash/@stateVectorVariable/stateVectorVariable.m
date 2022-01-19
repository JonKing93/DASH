classdef stateVectorVariable
%% stateVectorVariable  Design a variable in a state vector

properties

    %% Gridfile

    gridfile = "";                  % The absolute path to the .grid file for the variable
    dims = strings(1,0);            % The names of the defined dimensions in the .grid file
    gridSize = NaN(1,0);            % The size of each dimension in the .grid file

    %% Dimension design

    isState = true(1,0);            % Whether each dimension is a state dimension
    indices = cell(1,0);            % state / reference indices for each dimension
    stateSize = NaN(1,0);           % The number of state vector elements in the dimension
    ensSize = NaN(1,0);             % The number of ensemble members for the dimension

    %% Sequences

    sequenceIndices = cell(1,0);    % Sequence indices for ensemble dimensions
    sequenceMetadata = cell(1,0);   % Sequence metadata for each dimension

    %% Means

    meanType = zeros(1,0);          % 0: no mean, 1: unweighted mean, 2: weighted mean
    meanSize = NaN(1,0);            % The size of the dimension after taking the mean
    meanIndices = cell(1,0);        % Mean indices for ensemble dimensions
    omitnan = false(1,0);           % Nanflag options for each mean
    weights = cell(1,0);            % Weights for weighted means

    %% Metadata

    metadataType = zeros(1,0);      % 0: gridfile metadata, 1: user provided metadata, 2: convert metadata
    metadata = cell(1,0);           % User specified metadata
    convertFunction;                % Metadata conversion function handle
    convertArgs;                    % Metadata conversion function arguments

end


% Constructor
methods
    function[obj] = stateVectorVariable(grid)
    %% dash.stateVectorVariable.stateVectorVariable  Create a new stateVectorVariable object
    % ----------
    %   obj = dash.stateVectorVariable(grid)
    %   Creates a new stateVectorVariable object linked to a gridfile. By
    %   default, all dimensions are set as state dimensions, and all indices
    %   are selected for inclusion in the state vector.
    % ----------
    %   Inputs:
    %       grid (scalar gridfile object): The gridfile that contains the variable's data.
    %
    %   Outputs:
    %       obj (scalar stateVectorVariable): The new stateVectorVariable object
    %
    % <a href="matlab:dash.doc('dash.stateVectorVariable.stateVectorVariable
    
    % Update and record the gridfile fields
    grid.update;
    obj.gridfile = grid.file;
    obj.dims = grid.dims;
    obj.gridSize = grid.size;
    
    % Preallocate and initialize as state dimensions
    nDims = numel(obj.dims);

    obj.isState = true(1, nDims);
    obj.indices = cell(1, nDims);
    obj.stateSize = obj.gridSize;   % state dimension size is grid size
    obj.ensSize = ones(1, nDims);   % ens size of state dimensions is 1

    obj.sequenceIndices = cell(1, nDims);
    obj.sequenceMetadata = cell(1, nDims);

    obj.meanType = zeros(1, nDims);
    obj.meanSize = NaN(1, nDims);
    obj.meanIndices = cell(1, nDims);
    obj.omitnan = false(1, nDims);
    obj.weights = cell(1, nDims);

    obj.metadataType = zeros(1, nDims);
    obj.metadata = cell(1, nDims);
    obj.convertFunction = cell(1, nDims);
    obj.convertArgs = cell(1, nDims);

    end
end

end