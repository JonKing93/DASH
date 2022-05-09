function[members] = assertStaticMembers(obj, members, name, header)
%% ensemble.assertStaticMembers  Throw error if input is not members for a static ensemble
% ----------
%   members = obj.assertStaticMembers(members)
%   Throw error if input is not a vector of indices for for members of an
%   ensemble. If the input passes the assertion, returns ensemble members
%   as linear indices.
%
%   members = obj.assertStaticMembers(members, name, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       members: The input being checked
%       name (string scalar): The name of the input for error messages.
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       members (column vector, linear indices): The ensemble members
%           converted to a column vector of linear indices.
%
% <a href="matlab:dash.doc('ensemble.assertStaticMembers')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "members";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:ensemble:assertStaticMembers";
end

% Shortcut to select all indices
if isequal(members,-1) || isequal(members, 'all')
    members = (1:obj.totalMembers)';
    return
end
    
% Check the indices, convert to linear
logicalRequirement = 'have one element per saved ensemble member';
linearMax = 'the number of saved ensemble members';
members = dash.assert.indices(members, obj.totalMembers, name, ...
                                    logicalRequirement, linearMax, header);

% Require at least 1 member
if isempty(members)
    id = sprintf('%s:notEnoughMembers', header);
    error(id, '%s must include at least 1 ensemble member', name);
end

% Use column vector
members = members(:);

end