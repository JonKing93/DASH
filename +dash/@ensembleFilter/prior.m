function[obj] = prior(obj, X, whichPrior, header)
%% ensembleFilter.prior  Provide the prior for an assimilation filter
% ----------
%   obj = obj.prior(X, whichPrior, header)
%   Provide the prior(s) for an assimilation filter. The prior may either
%   be a numeric array, a scalar evolving ensemble object, or a vector of
%   ensemble objects. If a 

% Default
if ~exist('header','var')
    header = "DASH:ensembleFilter:prior";
end

% If empty, require empty whichPrior and reset prior
if isempty(X)
    if ~isempty(whichPrior)
        invalidWhichPriorError;
    end
    obj.X = [];

    % If Ye is missing, clear values
    if isempty(obj.Ye)
        obj.nMembers = 0;
        obj.nPrior = 0;
        obj.whichPrior = [];
    end

    % Clear time values and exit
    if isempty(obj.whichPrior) && isempty(obj.Y) && isempty(obj.whichR)
        obj.nTime = 0;
    end
    return
end


