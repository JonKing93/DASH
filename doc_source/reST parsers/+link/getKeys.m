function[keys] = getKeys(args)
%% Extract the unique set of keys from multiple sets of keys
% ----------
%   keys = link.getKeys(args)
% ----------
%   Inputs:
%       args (cell vector): Sets of keys. Elements are string vectors.
%
%   Outputs:
%       keys (string vector): The unique set of keys

keys = strings(0,1);
for k = 1:numel(args)
    keys = union(keys, args{k}, 'stable');
end

end