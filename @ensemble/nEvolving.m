function[nPriors] = nEvolving(obj)
%% ensemble.nPrior  Returns the number of priors for the elements of an ensemble array
% ----------
%   nPriors = obj.nPriors
%   Returns the number of ensembles implemented by each element of an array
%   of ensemble objects. 
% 
% 
% For each element, if the associated ensemble object
%   is a static ensemble, then 
% 
% 
% 
% ensemble array. For
%   each element, if the associated ensemble object is a static ensemble,
%   then the number of priors is 1. If the object implements an evolving
%   ensemble, then the number of priors is the number of evolving ensembles.
% ----------

nPriors = NaN(size(obj));
for p = 1:numel(obj)
    nPriors(p) = size(obj(p).members, 2);
end

end