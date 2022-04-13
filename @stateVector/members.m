function[nMembers] = members(obj)
%% stateVector.members  Return the number of ensemble members built by the state vector
% ----------
%   nMembers = <strong>obj.members</strong>
%   Returns the number of ensemble members that have been built by the
%   state vector object.
% ----------
%   Outputs:
%       nMembers (scalar integer): The number of ensemble members that have
%           been built by the state vector object.
%
% <a href="matlab:dash.doc('stateVector.members')">Documentation Page</a>

if obj.iseditable
    nMembers = 0;
elseif obj.isserialized
    nMembers = obj.nMembers_serialized;
else
    nMembers = size(obj.subMembers{1}, 1);
end

end