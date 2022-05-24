function[name] = name(obj)
%% particleFilter.name  Return a name for use in error messages
% ----------
%   name = obj.name
%   Returns a name for the particle filter object.
% ----------
%   Outputs:
%      name (string scalar): An identifying name for a particle filter
%
% <a href="matlab:dash.doc('particleFilter.name')">Documentation Page</a>

if ~strcmp(obj.label_, "")
    name = sprintf('particle filter "%s"', obj.label_);
else
    name = 'the particle filter';
end

end