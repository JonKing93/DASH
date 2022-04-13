function[varargout] = label(obj, label)
%% ensemble.label  Set or return the label of an ensemble object
% ----------
%   label = <strong>obj.label</strong>
%   Returns the current label of the ensemble object.
%
%   obj = <strong>obj.label</strong>(label)
%   Applies a new label to an ensemble object.
% ----------
%   Inputs:
%       label (string scalar): The new label to apply to the ensemble
%
%   Outputs:
%       label (string scalar): The current label of the ensemble object
%   obj (scalar ensemble object): The ensemble object with an updated label
%
% <a href="matlab:dash.doc('ensemble.label')">Documentation Page</a>

% Setup
header = "DASH:ensemble:label";
dash.assert.scalarObj(obj, header);

% Return current label
if ~exist('label','var')
    varargout = {obj.label_};

% Apply new label
else
    obj.label_ = dash.assert.strflag(label, 'label', header);
    varargout = {obj};
end

end