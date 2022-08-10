function[links] = args(title, type, args)
%% link.args  Get the input / output links from a set of signatures
% ----------
%   links = link.args(title, type, args)
% ----------
%   Inputs:
%       title (string scalar): Title of the function
%       type: (string scalar): "input" or "output"
%       args (string vector): List of input or output names
%
%   Outputs:
%       links (string vector): Links to the description of each input or output

links = strings(size(args));
for k = 1:numel(args)
    links(k) = sprintf("%s.%s.%s", title, type, args{k});
end

end