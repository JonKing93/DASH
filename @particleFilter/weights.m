function[w] = weights(pf, sse)
%% Returns weights for a particle filter.
%
% w = pf.weights(sse)
%
% ----- Inputs -----
%
% sse: Sum of squared errors from a particle filter
%
% ----- Outputs -----
%
% w: The weights

% Switch to the appropriate calculator
if pf.weightType==0
    w = pf.bayesWeights(sse);
elseif pf.weightType==1
    N = pf.weightArgs;
    w = pf.bestWeights(sse, N);
end

end