function[obj] = autoCouple(obj, varNames, auto)
%% Specify whether to automatically couple variables to new variables added
% or appended to the stateVector.
%
% obj = obj.autoCouple(varNames, auto)
%
% ----- Inputs -----
%
% varNames: A list of variable names for which auto-coupling options are
%    being set. A string vector or cellstring vector.
%
% auto: True (default) indicates that a variable should be automatically
%    coupled to new variables. False indicates that it should not. Use a
%    scalar logical to specify the behavior for all listed variables. Use a
%    logical behavior to specify the behavior for each variable listed in
%    varNames.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check, variable indices, editable
obj.assertEditable;
v = obj.checkVariables(varNames);

% Error check auto.
if ~islogical(auto)
    error('auto must be a logical');
elseif ~isscalar(auto)
    dash.assert.vectorTypeN(auto, [], numel(v), 'Since auto is not a scalar, it');
end

% Update
obj.auto_Couple(v) = auto;

end