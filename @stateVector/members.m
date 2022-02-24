function[nMembers] = members(obj)
%% stateVector.members  Return the number ensemble members built by the state vector
% ----------

if obj.iseditable
    nMembers = 0;
elseif obj.isserialized
    nMembers = obj.nMembers_serialized;
else
    nMembers = size(obj.subMembers{1}, 1);
end

end