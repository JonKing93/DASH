function[varargout] = label(obj, label)
%% stateVector.label  Set or return the label of a stateVector object
% ----------
%   label = <strong>obj.label</strong>
%   Returns the current label of the stateVector object.
%
%   obj = <strong>obj.label</strong>(label)
%   Applies a new label to a stateVector object.
% ----------
%   Inputs:
%       label (string scalar): The new label to apply to a stateVector object.
%
%   Outputs
%       label (string scalar): The current label of a stateVector object.
%       obj (scalar stateVector object): The stateVector object with an
%           updated label.
%
% <a href="matlab:dash.doc('stateVector.label')">Documentation Page</a>

% Setup
header = "DASH:stateVector:label";
dash.assert.scalarObj(obj, header);

% Return current label
if ~exist('label','var')
    varargout = {obj.label_};

% Apply new label
else
    obj.assertEditable;
    obj.label_ = dash.assert.strflag(label, 'label', header);
    varargout = {obj};
end

end

