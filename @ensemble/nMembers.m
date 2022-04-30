function[nMembers] = nMembers(obj, scope)
%% ensemble.nMembers  Returns the number of ensemble members for the elements of an ensemble array
% ----------
%   nMembers = obj.nMembers
%   Returns the number of ensemble members for each element of an ensemble
%   array. If an element is a static ensemble, returns the total number of
%   used ensemble members. If an element implements an evolving ensemble,
%   returns the number of ensemble members per prior.
% 
%   ... = obj.nMembers(scope)
%   ... = obj.nMembers(false|"u"|"used")
%   ... = obj.nMembers( true|"f"|"file")
%   Indicate the scope in which to count ensemble members. If false,
%   behaves identically to the previous sytax. If true, returns the total
%   number of ensemble members stored in the .ens file for each element of
%   an ensemble array.   
% ----------

% Parse the scope
header = "DASH:ensemble:nMembers";
useFile = obj.parseScope(scope, header);

% Count members
nMembers = NaN(size(obj));
for m = 1:numel(obj)
    if useFile
        nMembers(m) = obj(m).nMembers_;
    else
        nMembers(m) = size(obj(m).members, 1);
    end
end

end
