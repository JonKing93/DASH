function[nMembers] = nMembers(obj, scope)
%% ensemble.nMembers  Return the number of members used by the ensemble objects in an array
% ----------
%   nMembers = <strong>obj.nMembers</strong>
%   Returns the number of state vector rows being used for each element of
%   an ensemble array. For evolving ensembles, the number of members is the
%   number of ensemble members per ensemble in an evolving set.
%
%   nMembers = <strong>obj.nMembers</strong>(scope)
%   ... = <strong>obj.nMembers</strong>(false|"u"|"used")
%   ... = <strong>obj.nMembers</strong>( true|"f"|"file")
%   Indicate the scope in which to count members. If "used"|"u"|false, behaves
%   identically to the previous syntax and counts the number of members
%   used by each ensemble. If "file"|"f"|true, counts the number of
%   ensemble members saved in the .ens file for each ensemble.
% ----------
%   Inputs:
%       scope (scalar logical | string scalar): Indicates the scope in
%           which to count ensemble members.
%           ["used"|"u"|false (default)]: Counts members used by the ensemble
%           ["file"|"f"|true]: Counts members saved in the .ens file
%
%   Outputs:
%       nMembers (numeric array): The number of members in each element
%           of an ensemble array. Has the same size as obj.
%
% <a href="matlab:dash.doc('ensemble.nMembers')">Documentation Page</a>

% Default and parse scope
header = "DASH:ensemble:nMembers";
if ~exist('scope','var') || isempty(scope)
    scope = "used";
end
useFile = obj.parseScope(scope, header);

% Count members
nMembers = NaN(size(obj));
for k = 1:numel(obj)
    if useFile
        nMembers(k) = obj(k).totalMembers;
    else
        nMembers(k) = size(obj(k).members_, 1);
    end
end

end