function[name] = name(obj)
%% kalmanFilter.name  Return a name for use in error messages
% ----------
%   name = <strong>obj.name</strong>
%   Returns a name for the Kalman filter object.
% ----------
%   Outputs:
%       name (string scalar): An identifying name for a Kalman filter
%
% <a href="matlab:dash.doc('kalmanFilter.name')">Documentation Page</a>

if ~strcmp(obj.label_, "")
    name = sprintf('Kalman filter "%s"', obj.label_);
else
    name = 'the Kalman filter';
end

end