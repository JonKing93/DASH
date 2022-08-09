function[nEvolving] = nEvolving(obj)
%% ensemble.nEvolving  Return the number of evolving ensembles implemented by ensemble objects in an array
% ----------
%   nEvolving = <strong>obj.nEvolving</strong>
%   Returns the number of evolving ensembles implemented by each element of
%   an ensemble array. For static ensembles, this value is always 1. For
%   evolving ensembles, this is the number of ensembles in the evolving set.
% ----------
%   Outputs:
%       nEvolving (numeric array): The number of evolving ensembles
%           implemented by each element of an ensemble array. Has the same 
%           size as obj.
%
% <a href="matlab:dash.doc('ensemble.nEvolving')">Documentation Page</a>

% Count ensembles
nEvolving = NaN(size(obj));
for k = 1:numel(obj)
    nEvolving(k) = size(obj(k).members_, 2);
end

end