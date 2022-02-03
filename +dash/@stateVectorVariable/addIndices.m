function[indices] = addIndices(obj, d)
%% dash.stateVectorVariable.addIndices  Propagates mean indices over sequence indices for an ensemble dimension
% ----------
%   indices = obj.addIndices(d)
%   Propagates the mean indices over the sequence indices for the indexed
%   dimension. The returned indices are useful when building ensemble members.
%   These indices can be added to a reference index in order to determine
%   all gridfile indices that must be loaded in order to build an ensemble
%   member.
%
%   The returned add indices are organized such that the integers
%   corresponding to sequence elements are consecutive. The integers
%   iterate over mean indices in sequence element 1, then mean indices in
%   sequence element 2, etc.
% ----------
%   Inputs:
%       d (scalar linear index): The index of an ensemble dimension in the
%           state vector variable.
%      
%   Outputs:
%       indices (vector, integers): The integers that should be added to
%           each reference index in order to determine the gridfile indices
%           required to build the corresponding ensemble member.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.addIndices')">Documentation Page</a>

indices = obj.meanIndices{d} + obj.sequenceIndices{d}';
indices = indices(:);

end