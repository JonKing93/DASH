function[M] = buildEnsemble(obj, member)
%% Builds an ensemble for the stateVectorVariable
%
% M = obj.buildEnsemble(draws)
%
% ----- Inputs -----
%
% member: The linear index that specifies which ensemble member to build.
%    Ensemble members are indexed by iterating through ensemble dimension
%    elements in column major order.
%
% ----- Outputs -----
%
% M: The ensemble for the variable. A numeric matrix

%%%%%% Currently building architecture for a single draw

% Initialize the load indices with any state indices
nDims = numel(obj.dims);
indices = cell(1, nDims);
indices(obj.isState) = obj.indices(obj.isState);

% Convert the draw index into reference indices for the ensemble dimensions
siz = obj.ensSize(~obj.isState);
[indices{~obj.isState}] = ind2sub(siz, member);

% Get mean indices for each ensemble dimension
d = find(~obj.isState);
for k = 1:numel(d)
    meanIndices = obj.mean_Indices{d(k)};
    if isempty(meanIndices)
        meanIndices = 0;
    end
    
    % Propagate mean indices over sequence indices. Add to reference indices
    ensIndices = meanIndices + obj.seqIndices{d(k)}';
    ensIndices = ensIndices(:);
    indices{d(k)} = indices{d(k)} + ensIndices;
end

% Load the data from the .grid file
grid = gridfile(obj.file);
data = grid.load(obj.dims, indices);

end
