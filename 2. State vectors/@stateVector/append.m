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
if ~isa(secondVector, 'stateVector')
    error('secondVector must be a stateVector object');
elseif ~isscalar(secondVector)
    error('secondVector must be a scalar stateVector object.');
end

% Check there are no naming conflicts
names1 = obj.variableNames;
names2 = secondVector.variableNames;
duplicate = intersect(names1, names2);
if ~isempty(duplicate)
    duplicateNameError(obj, secondVector, duplicate);
end

% Notify user of autocoupling
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
function[] = duplicateNameError(obj, secondVector, duplicate)
title2 = secondVector.errorTitle;
if strcmp(title2, obj.defaultName)
    title2 = "secondVector";
end
error(['Cannot append %s to %s because both contain variables named %s. ',...
    'To change variable names, see "stateVector.renameVariables".'], ...
    obj.errorTitle, title2, dash.messageList(duplicate));
end
function[] = notifyAutocoupling(obj, names1, names2)

% Only notify if there are variables to couple and the user enabled
% notifications
if obj.verbose && numel(names1)>0 && numel(names2)>0
    fprintf('\nCoupling %s to %s.\n', dash.messageList(names1), dash.messageList(names2));
end

end