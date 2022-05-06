function[members] = members(obj, ensembles)
%% ensemble.members  Return the ensemble members for an ensemble
% ----------
%   members = obj.members
%   Returns the indices of the ensemble members being used by the ensemble
%   object. If the ensemble object implements a static ensemble, returns
%   the indices of all used ensemble members. If the ensemble object 
%   implements evolving ensembles, returns the indices of the ensemble
%   members in each evolving ensemble. Each column holds the indices for a
%   particular ensemble. The order of columns matches the order of
%   ensembles in the evolving ensemble.
%
%   members = obj.members(evolvingLabels)
%   members = obj.members(e)
%   members = obj.members(-1)
%   Returns the indices of the ensemble members being used by the specified
%   ensembles in an evolving ensemble. Each column holds the indices for a
%   particular ensemble. The order of columns matches the order of input
%   ensembles. If the index is -1, returns the ensemble members for all
%   evolving ensembles.
%
%   members = obj.members(label)
%   members = obj.members(-1 | 1)
%   If the ensemble object implements a static ensemble, you may still use
%   the first input to "select" the ensemble. However, the ensemble can only
%   be selected using the label of the ensemble object, 1, or -1.
%
%   members = obj.members(0)
%   Returns the indices of the all the ensemble members saved in the .ens
%   file.
% ----------
%   Inputs:
%       evolvingNames (string vector): The labels of specific ensembles in
%           an evolving ensemble. If the ensemble object implements a
%           static ensemble, can only use the label of the ensemble object.
%       e (0 | -1 | linear indices | logical vectorf): The indices of ensembles in an
%           evolving ensemble. If -1, selects all ensemble implemented by
%           the ensemble object. If the ensemble object implements a static
%           ensemble, can only be 1 or -1. If 0, returns the indices of
%           all ensemble members saved in the .ens file.
%
%   Outputs:
%       members (array, positive integers, [nMembers x nEnsembles]):
%           The indices of the ensemble members in the specified ensembles.
%           Indices mark the location of the used ensemble members within
%           the total set of ensemble members saved in the .ens file.
%
% <a href="matlab:dash.doc('ensemble.members')">Documentation Page</a>

% Setup
header = "DASH:ensemble:members";
dash.assert.scalarObj(obj, header);

% Default
if ~exist('ensembles','var')
    ensembles = -1;
end

% If 0, return file members directly
if isequal(ensembles, 0)
    members = (1:obj.totalMembers)';
    
% Otherwise, parse ensembles and return members
else
    e = obj.ensembleIndices(ensembles);
    members = obj.members_(:,e);
end

end