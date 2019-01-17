function[sM] = takeDimMeans(sM, takeMean)

% Get the mean dimensions
meanDim = find(takeMean);
nDim = numel(meanDim);

% For each dimension
for d = 1:meanDim
    
    % Take the mean
    sM = mean( sM, meanDex(d) );
end

end