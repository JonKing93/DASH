function[members] = members(obj, ensembles)
%% ensemble.members  Return the ensemble members for an ensemble
% ----------
%   members = <strong>obj.members</strong>
%   Returns the ensemble members being used by the ensemble object. The
%   elements of the output array list the indices of ensembles members
%   saved in the .ens file. If the ensemble object implements a static
%   ensemble, returns the indices of all used ensemble members as a column
%   vector. If the ensemble object implements an evolving ensemble, the
%   output array will be a matrix. Each column will hold the indices for a
%   particular ensemble in the evolving set, and the order of columns will
%   match the order of ensembles in the evolving set.
%
%   members = <strong>obj.members</strong>(labels)
%   members = <strong>obj.members</strong>(e)
%   members = <strong>obj.members</strong>(-1)
%   Returns the ensemble members for the specified ensembles in an evolving
%   ensemble. Each column of the output array holds the ensemble members
%   for a specified matrix, and the order of columns matches the order of
%   specified ensembles. If the index is -1, returns the ensemble members
%   for all ensembles in the evolving set.
%
%   members = <strong>obj.members</strong>(0)
%   Returns the indices of all ensemble members saved in the .ens file.
% ----------
%   Inputs:
%       e (0 | -1 | linear indices | logical vector): Indicates the
%           ensembles for which to return ensemble members. If 0, returns
%           all ensemble members saved in the .ens file. Otherwise,
%           indicates specific ensembles in the evolving set. If -1,
%           selects all ensembles in the evolving set. If a logical vector,
%           must have one element per ensemble in the evolving set.
%           Otherwise, use the linear indices of ensembles in the evolving set.
%       labels (string vector): The labels of specific ensembles in the
%           evolving set. You can only use labels to reference ensembles
%           that have unique labels. If multiple ensembles in the evolving
%           set share the same label, reference them using indices instead.
%
%   Outputs:
%       members (array, positive integers, [nMembers x nEnsembles]):
%           The ensemble members for the specified ensembles. Each element 
%           of "members" lists the index of an ensemble member saved in the
%           .ens file. The columns of "members" list the ensemble members
%           for different ensembles.
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
    
% Otherwise, parse ensembles indices and return members
else
    e = obj.evolvingIndices(ensembles, true, header);
    members = obj.members_(:,e);
end

end