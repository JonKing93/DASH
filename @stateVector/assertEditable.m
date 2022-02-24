function[] = assertEditable(obj, header)
%% stateVector.assertEditable  Throw error if state vector is not editable
% ----------
%   <strong>obj.assertEditable</strong>
%   Throws an error if a stateVector array contains elements that have been
%   finalized and are no longer editable. A state vector becomes finalized
%   when it is used to build a state vector ensemble. State vector objects
%   stored in .ens files are typically not editable.
%
%   <strong>obj.assertEditable</strong>(header)
%   Customize thrown error IDs
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
% 
% <a href="matlab:dash.doc('stateVector.assertEditable')">Documentation Page</a>

% Default header
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVector:assertEditable";
end

% Empty case cannot be finalized
if isempty(obj)
    return
end

% Setup if any elements are finalized
if ~all([obj.iseditable])
    id = sprintf('%s:stateVectorNotEditable', header);

    % Array or scalar
    if ~isscalar(obj)
        ME = MException(id, ['The stateVector array contains elements that ',...
            'are no longer editable. (These elements have been finalized ',...
            'and used to build state vector ensembles).']);
    else
        ME = MException(id, ['%s is no longer editable. (It has been finalized ',...
            'and used to build a state vector ensemble).'], obj.name(true));
    end

    % Throw error
    throwAsCaller(ME);
end

end