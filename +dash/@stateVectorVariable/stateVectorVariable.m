classdef stateVectorVariable
%% dash.stateVectorVariable  Implement a variable in a state vector
% ----------
%   The stateVectorVariable class implements an object that describes a
%   variable in a state vector. Each object holds the design parameters for
%   a single variable. These design parameters include:
%
%       1. State and ensemble dimensions
%       2. Sequences
%       3. Means, and
%       4. Metadata options.
%
%   The class also implements a number of utilities for building state
%   vector ensembles; these include removing ensemble members with incomplete
%   sequences/means, removing ensemble members that overlap previously
%   built members, and processing metadata options.
%
%   The stateVectorVariable class is designed to build variables from data
%   catalogued in a gridfile. However, methods that update the variable's
%   design parameters do not require gridfile access. The gridfile is only
%   required to initially create a variable, and when building a state
%   vector ensemble.
%
%   The class framework allows multiple stateVectorVariable objects to be 
%   stored as a vector, which is utilized by the stateVector class.
%   However, such vectors are highly nested and are slow to save directly.
%   Instead, these vectors should be serialized before saving, and
%   deserialized upon load. See the "serialize" and "deserialize" commands
%   to implement these options.
% ----------
% dash.stateVectorVariable methods:
%
% Create:
%   stateVectorVariable - Create a new stateVectorVariable object
%
% Design:
%   design              - Design the dimensions of a state vector variable
%   sequence            - Apply a sequence over ensemble dimensions of a variable
%   mean                - Take a mean over dimensions of a variable
%   weightedMean        - Apply a weighted mean over dimensions of a variable
%   metadata            - Set metadata options for ensemble dimensions of a variable
%
% Dimensions:
%   dimensions          - List the dimensions of a variable
%   dimensionIndices    - Return the indices of dimensions within a variable
%
% gridfile interactions:
%   validateGrid        - Check that a gridfile matches a variable's recorded gridfile parameters
%   getMetadata         - Process and return metadata along a dimension
%
% Utilities for build:
%   finalize            - Fill placeholder values in a variable
%   addIndices          - Propagate mean indices over sequence indices   
%
% Select ensemble members:
%   trim                - Remove reference indices that would cause an incomplete sequence or incomplete mean
%   matchMetadata       - Order reference indices so that ensemble metadata matches an ordering set
%   ensembleSizes       - Return the sizes and names of ensemble dimensions
%   removeOverlap       - Remove ensemble members that overlap previous members
%
% Build members:
%   indexLimits         - Return limits of gridfile dimension indices required to load ensemble members
%   parametersForBuild  - Return parameters used for building ensemble members
%   buildMembers        - Build a set of ensemble members
%
% Serialization:
%   serialize           - Convert variables to a struct that supports fast saving / loading
%   deserialize         - Rebuild variables from a serialized struct
%
% Unit tests:
%   tests               - Unit tests for the dash.stateVectorVariable class
%
% <a href="matlab:dash.doc('dash.stateVectorVariable')">Documentation Page</a>

properties

    %% Gridfile

    dims = strings(1,0);            % The names of the defined dimensions in the .grid file
    gridSize = NaN(1,0);            % The size of each dimension in the .grid file

    %% Dimension design

    isState = true(1,0);            % Whether each dimension is a state dimension
    indices = cell(1,0);            % state / reference indices for each dimension
    stateSize = NaN(1,0);           % The number of state vector elements in the dimension
    ensSize = NaN(1,0);             % The number of ensemble members for the dimension

    %% Sequences

    hasSequence = false(1,0);       % Whether a dimension has a sequence
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
    metadata_ = cell(1,0);          % User specified metadata
    convertFunction = cell(1,0)     % Metadata conversion function handle
    convertArgs = cell(1,0);        % Metadata conversion function arguments

end

methods

    % Design
    obj = design(obj, dims, isstate, indices, header);
    obj = sequence(obj, dims, indices, metadata, header);
    obj = metadata(obj, dims, type, arg1, arg2, header);
    obj = mean(obj, dims, indices, omitnan, header);
    obj = weightedMean(obj, dims, weights, header);

    % Gridfile interactions
    [metadata, failed, cause] = getMetadata(obj, d, grid, header);
    [isvalid, cause] = validateGrid(obj, grid, header);

    % Dimensions
    dimensions = dimensions(obj, type);
    d = dimensionIndices(obj, dimensions);

    % Select ensemble members
    [sizes, dimNames] = ensembleSizes(obj);
    obj = trim(obj);
    obj = matchMetadata(obj, dims, metadata, grid);
    subMembers = removeOverlap(obj, dims, subMembers);

    % Build members
    obj = finalize(obj);
    indices = addIndices(obj, d);
    limits = indexLimits(obj, dims, subMembers, includeState);
    parameters = parametersForBuild(obj);
    X = buildMembers(obj, dims, subMembers, grid, source, parameters);

    % Serialization
    s = serialize(obj);
end
methods (Static)
    obj = deserialize(s);
end

% Constructor
methods
    function[obj] = stateVectorVariable(grid)
    %% dash.stateVectorVariable.stateVectorVariable  Create a new stateVectorVariable object
    % ----------
    %   obj = dash.stateVectorVariable
    %   Returns a new, empty stateVectorVariable object. The object is not
    %   linked to a gridfile, so has no dimensions.
    %
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

    % Empty call syntax
    if nargin==0
        return
    end

    % Record the gridfile fields
    [obj.dims, obj.gridSize] = grid.dimensions;
    
    % Preallocate and initialize as state dimensions
    nDims = numel(obj.dims);

    obj.isState = true(1, nDims);
    obj.indices = cell(1, nDims);
    obj.stateSize = obj.gridSize;   % state dimension size is grid size
    obj.ensSize = ones(1, nDims);   % ens size of state dimensions is 1

    obj.hasSequence = false(1, nDims);
    obj.sequenceIndices = cell(1, nDims);
    obj.sequenceMetadata = cell(1, nDims);

    obj.meanType = zeros(1, nDims);
    obj.meanSize = NaN(1, nDims);
    obj.meanIndices = cell(1, nDims);
    obj.omitnan = false(1, nDims);
    obj.weights = cell(1, nDims);

    obj.metadataType = zeros(1, nDims);
    obj.metadata_ = cell(1, nDims);
    obj.convertFunction = cell(1, nDims);
    obj.convertArgs = cell(1, nDims);

    end
end

end