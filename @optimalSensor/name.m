function[name] = name(obj)
%% optimalSensor.name  Return a name for use in error messages
% ----------
%   name = <strong>obj.name</strong>
%   Returns a name for the optimal sensor object.
% ----------
%   Outputs:
%       name (string scalar): An identifying name for an optimal sensor
%
% <a href="matlab:dash.doc('optimalSensor.name')">Documentation Page</a>

if ~strcmp(obj.label_, "")
    name = sprintf('optimal sensor "%s"', obj.label_);
else
    name = 'the optimal sensor';
end

end