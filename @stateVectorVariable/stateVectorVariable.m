classdef stateVectorVariable
%% stateVectorVariable  Implement the design for a variable in a state vector
% ----------
%
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
% Metadata conversion:
%   setMetadata
%   convertMetadata
%
% Reset:
%   resetMean
%   resetSequence
%
% Summary Information:
%   info
%   dimensions


properties (SetAccess = private)
    name;
    file;
    dims;
    gridSize;
    
    size;
    isState;
    indices;
    
    sequenceIndices;
    sequenceMetadata;
    
    takeMean;
    meanSize;