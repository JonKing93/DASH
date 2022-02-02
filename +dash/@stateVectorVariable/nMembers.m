function[nMembers] = nMembers(obj)
%% dash.stateVectorVariable.nMembers  Return the number of possible ensemble members for a variable
% ----------
%   nMembers = obj.nMembers
%   Returns the number of possible ensemble members for the variable. This
%   number does not take overlap prohibitions into consideration. Rather,
%   it is the product of the number of reference indices along each
%   ensemble dimension.
% ----------
%   Outputs:
%       nMembers (scalar integer): The number of possible ensemble members
%           for the variable.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.nMembers')">Documentation Page</a>
nMembers = prod(obj.ensSize);
end