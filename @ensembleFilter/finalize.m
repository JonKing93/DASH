function[obj] = finalize(obj, actionName)
%% Checks that a filter has all essential fields and fills empty whichPrior
%
% obj = obj.finalize(actionName)
%
% ----- Inputs -----
%
% actionName: The action that the filter is being finalized for. A string
%
% ----- Outputs -----
%
% obj: The updated ensembleFilter object

% Check for essential inputs
assert(~isempty(obj.Y), sprintf('You must provide observations before you %s', actionName));
assert(~isempty(obj.Ye), sprintf('You must provide proxy estimates before you %s.', actionName));

% Fill in empty whichPrior and whichRcov
if isempty(obj.whichPrior)
    obj.whichPrior = ones(obj.nTime, 1);
end
if isempty(obj.whichR)
    obj.whichR = ones(obj.nTime, 1);
end

end
