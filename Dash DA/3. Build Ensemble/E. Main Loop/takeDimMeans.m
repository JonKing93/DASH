function[sM] = takeDimMeans(sM, takeMean, nanflag)

% Get the mean dimensions
meanDim = find(takeMean);
nanflag = nanflag(meanDim);

% For each dimension
for m = 1:numel(meanDim)
    
    % Take the mean
    sM = mean( sM, meanDim(m), nanflag{m} );
end

end