function[parameters] = parametersForBuild(obj)
%% dash.stateVector.parametersForBuild  Organize and return parameters needed to build ensemble members for a variable
% ----------
%   parameters = obj.parametersForBuild
%   Organizes parameters needed to build ensemble members for a state
%   vector variable into a struct.
% ----------
%   Inputs:
%       loadAllMembers (scalar logical): Whether the variable should
%           attempt to load all ensemble members simultaneously.
%
%   Outputs:
%       parameters (scalar struct):
%           .loadedSize (vector, positive integers): The size of a raw ensemble
%               member. This is the size of the ensemble member before any
%               means are taken. Mean and sequence elements are separated
%               from one another.
%           .meanDims (vector, linear index): The index of the dimension
%               containing mean elements in the raw ensemble member.
%               (Because mean and sequence elements are separated from one
%               another, variable dimensions may actually span 2 dimensions
%               of the loaded ensemble member).
%           .nState (scalar positive integer): The number of state vector
%               elements in the final ensemble member
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.parametersForBuild')">Documentation Page</a>

% Get the size of a loaded ensemble members
meanSize = obj.meanSize;
meanSize(isnan(meanSize)) = 1;
loadedSize = obj.stateSize .* meanSize;

% Record location of dimensions for means
nDims = numel(obj.dims);
meanDims = 1:nDims;

% Adjust size and mean dimensions for multiple sequence elements
for d = nDims:-1:1
    if ~obj.isState(d) && obj.stateSize(d)>1
        loadedSize = [loadedSize(1:d-1), obj.meanSize(d), obj.stateSize(d), loadedSize(d+1:end)];
        meanDims(d+1:end) = meanDims(d+1:end)+1;
    end
end

% Get the number of state vector elements
nState = prod(obj.stateSize);

% Organize output
parameters = struct('loadedSize', loadedSize, 'meanDims', meanDims, ...
    'nState', nState);

end