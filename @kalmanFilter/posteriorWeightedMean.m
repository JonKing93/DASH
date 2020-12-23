function[kf] = posteriorWeightedMean(kf, weights)

% Add to the calculations array
k = numel(kf.Q)+1;
kf.Q{k,1} = posteriorWeightedMean(weights);

end