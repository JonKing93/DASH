function[obj] = append(obj, secondVector)
%% Appends another state vector to the end of the current vector. Couples
% any auto-couple variables in the current vector with auto-couple
% variables in the second vector.
%
% obj = obj.append(secondVector)
%
% ----- Inputs -----
%
% secondVector: A second stateVector object
%
% ----- Outputs -----
%
% obj: A stateVector object for the concatenated state vectors.

% Error check
obj.assertEditable;
dash.assertScalarType(secondVector, 'secondVector', 'stateVector', 'stateVector object');

% Check there are no naming conflicts
title2 = secondVector.errorTitle;
if strcmp(title2, obj.defaultName)
    title2 = "secondVector";
end
obj.checkVariableNames(secondVector.variableNames, [], [], sprintf('append %s to', title2));

% Notify user of autocoupling
names1 = obj.variableNames;
names2 = secondVector.variableNames;
couple1 = names1(obj.auto_Couple);
couple2 = names2(secondVector.auto_Couple);
notifyAutocoupling(obj, couple1, couple2);

% Update
new = numel(names1) + (1:numel(names2));
obj.variables(new,1) = secondVector.variables;
obj.overlap(new,1) = secondVector.overlap;
obj.coupled(new, new) = secondVector.coupled;
obj.auto_Couple(new,1) = secondVector.auto_Couple;

% Couple auto-coupled variables
obj = obj.couple([couple1; couple2]);

end

% Messages
function[] = notifyAutocoupling(obj, names1, names2)

% Only notify if there are variables to couple and the user enabled
% notifications
if obj.verbose && numel(names1)>0 && numel(names2)>0
    fprintf('\nCoupling %s to %s.\n', dash.messageList(names1), dash.messageList(names2));
end

end