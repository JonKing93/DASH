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
end

% Constructor
methods
    function[obj] = stateVectorVariable(grid, header)
    %% dash.stateVectorVariable.stateVectorVariable  Create a new stateVectorVariable object
    % ----------
    %   obj = dash.stateVectorVariable(grid)
    %   Creates a new stateVectorVariable object linked to a .grid file. By
    %   default, all dimensions are set as state dimensions, and all indices
    %   are selected for inclusion in the state vector.
    %
    %   obj = dash.stateVectorVariable(grid, svName, header)
    %   Customize thrown error messages.
    % ----------
    %   Inputs:
    %       grid (scalar string | scalar gridfile object): The gridfile that
    %           contains the variable's data.
    %
    %   Outputs:
    %       obj (scalar stateVectorVariable): The new stateVectorVariable object
    %
    % <a href="matlab:dash.doc('dash.stateVectorVariable.stateVectorVariable
    
    % Get the gridfile object. 
    if isa(grid, 'gridfile')
        dash.assert.scalarType(grid, [], header);
        grid.update;
    elseif dash.is.strflag(grid)
        grid = gridfile(grid);
    else
        invalidGridfileError(svName, header);
    end
    
    % Update the gridfile fields
    obj.gridfile = grid.file;
    obj.dims = grid.dims;
    obj.gridSize = grid.size;
    
    % Preallocate other fields
    nDims = numel(obj.dims);

    isState = true(1, nDims);
    indices = cell(1, nDims);
    stateSize = NaN(1, nDims);
    ensSize = NaN(1, nDims);

    sequenceIndices = cell(1, nDims);
    sequenceMetadata = cell(1, nDims);

    end

















