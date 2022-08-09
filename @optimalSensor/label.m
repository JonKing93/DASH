function[varargout] = label(obj, label)
%% optimalSensor.label  Return or set the label of an optimal sensor
% ----------
%   label = <strong>obj.label</strong>
%   Returns the label of the current optimalSensor object.
%
%   obj = <strong>obj.label</strong>(label)
%   Applies a new label to the optimalSensor object
% ----------
%   Inputs:
%       label (string scalar): A new label for the optimal sensor
%
%   Outputs:
%       label (string scalar): The current label of the object
%       obj (scalar optimalSensor object): The object with an updated label.
%
% <a href="matlab:dash.doc('optimalSensor.label')">Documentation Page</a>

% Setup
header = "DASH:optimalSensor:label";
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