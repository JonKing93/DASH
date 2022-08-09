function[obj] = static(obj, members)
%% ensemble.static  Design static ensembles
% ----------
%   obj = <strong>obj.static</strong>
%   obj = <strong>obj.static</strong>(-1)
%   obj = <strong>obj.static</strong>('all')
%   Implements a static ensemble that uses every ensemble member saved in
%   the .ens file.
%
%   obj = <strong>obj.static</strong>(members)
%   Implements a static ensemble that uses the specified ensemble members.
% ----------
%   Inputs:
%       members (-1 | logical vector | vector, linear indices): Indicates
%           the ensemble members that should be used by the static
%           ensemble. If -1, selects all ensemble members saved in the .ens
%           file. If a logical vector, should have one element per saved
%           ensemble member. If a numeric vector, elements should list
%           indices of ensemble members in the .ens file.
%
%   Outputs:
%       obj (scalar ensemble object): The ensemble object updated to 
%           implement a static ensemble.
%
% <a href="matlab:dash.doc('ensemble.static')">Documentation Page</a>

% Setup
header = "DASH:ensemble:static";
dash.assert.scalarObj(obj, header);

% Default
if ~exist('members','var')
    members = -1;
end

% Check and update members
obj.members_ = obj.assertStaticMembers(members, 'members', header);

% Clear evolving properties
obj.isevolving = false;
obj.evolvingLabels_ = "";

end