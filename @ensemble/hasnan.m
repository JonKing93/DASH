function[nanMembers] = hasnan(obj, varNames)
%% Indicates whether ensemble members contain NaN elements for variables
% in a state vector ensemble.
%
% nanMembers = obj.hasnan
% Returns a row vector that indicates which ensemble members contain NaN
% elements.
%
% nanVars = obj.hasnan(varNames)
% Returns a logical matrix that indicates whether specified variables have
% NaN elements in ensemble members.
%
% nanVars = obj.hasnan([])
% Indicates whether variables have NaN elements in ensemble members for
% each variable in a state vector.
%
% ----- Inputs -----
%
% varNames: A list of variables in a state vector. A string vector or
%    cellstring vector.
%
% ----- Outputs -----
%
% nanMembers: A logical row vector with one element per ensemble member. True
%    elements indicate that the ensemble member contains NaN elements.
%
% nanVars: A logical matrix with one column per ensemble member. Each row
%    indicates whether a particular variable has NaN elements in each
%    ensemble member.

% If no inputs, return summary for all variables
if ~exist('varNames','var')
    nanMembers = any(obj.has_nan,1);
    return;
end

% Otherwise, return for specified variables
allVars = obj.metadata.variableNames;
if isempty(varNames)
    v = 1:numel(allVars);
else
    v = dash.checkStrsInList(varNames, allVars, 'varNames', 'variable in the state vector');
end
nanMembers = obj.has_nan(v,:);

end    