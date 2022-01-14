classdef stateVectorVariable
%% stateVectorVariable  Design a variable in a state vector
% ----------
% stateVectorVariable methods:
%
% Variable:
%   stateVectorVariable
%   rename
%
% Design:
%   design
%   sequence
%   mean
%   weightedMean
%
% Metadata:
%   setMetadata/useMetadata
%   convertMetadata
%
% Reset:
%   resetMean
%   resetSequence
%
% Serialize:
%   serialize
%   deserialize
%
% Summary Information:
%   info
%   dimensions



properties
    % Parent vector name (used for error messages)
    parent;

    % Gridfile
    gridfile = "";
    dims = strings(1,0);
    gridSize = NaN(1,0);

    % Dimension design
    isState = true(1,0);
    indices = cell(1,0);
    stateSize = NaN(1,0);
    ensSize = NaN(1,0);

    % Sequences
    sequenceIndices = cell(1,0);
    sequenceMetadata = cell(1,0);

    % Mean
    takeMean = false(1,0);
    meanSize = NaN(1,0);
    meanIndices = cell(1,0);
    omitnan = strings(1,0);

    % Weighted mean
    hasWeights = false(1,0);
    weights = cell(1,0);

    % Metadata

end

methods

    % Design
    obj = stateDimension(d, indices);
    obj = ensembleDimension(d, indices);



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
    
    % Preallocate
    nDims = numel(obj.dims);

    obj.isState = true(1, nDims);
    obj.indices = cell(1, nDims);
    obj.stateSize = NaN(1, nDims);
    obj.ensSize = NaN(1, nDims);

    obj.sequenceIndices = cell(1, nDims);
    obj.sequenceMetadata = cell(1, nDims);

    end
end

end