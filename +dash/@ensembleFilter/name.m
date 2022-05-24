function[name] = name(obj)
%% dash.ensembleFilter.name  Return a name for use in error messages
% ----------
%   name = obj.name
%   Returns a name for the filter object.
% ----------
%   Outputs:
%      name (string scalar): An identifying name for a filter objectf
%
% <a href="matlab:dash.doc('dash.ensembleFilter.name')">Documentation Page</a>

if ~strcmp(obj.label_, "")
    name = sprintf('filter "%s"', obj.label_);
else
    name = 'the filter';
end

end