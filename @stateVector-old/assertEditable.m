function[] = assertEditable(obj)
%% Checks that a stateVector is still editable and not associated with an
% ensemble.
%
% obj.assertEditable

if ~obj.editable
    name = char(obj.errorTitle);
    name(1) = 'T';
    error(['This stateVector object is associated with a state vector ensemble, so can no longer ',...
        'be edited. (It was probably provided as output from a call to ',...
        'stateVector.build).'], name);
end

end