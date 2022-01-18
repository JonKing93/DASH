function[] = assertEditable(obj, header)
%% stateVector.assertEditable  Throw error if state vector is not editable
% ----------
%   <strong>obj.assertEditable</strong>
%   Throws an error if a state vector is not editable. A state vector is
%   not editable if it is associated with a built ensemble. State vector
%   objects stored in .ens files are typically not editable.
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

% Throw error if not editable
if ~obj.iseditable
    id = sprintf('%s:stateVectorNotEditable', header);
    error(id, ['%s is associated with an existing state vector ensemble ',...
        'and cannot be edited.'], obj.name);
end

end