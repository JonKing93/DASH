function[sM] = takeDimMeans(sM, takeMean, nanflag)
%% Takes the appropriate dimensional means for loaded data
%
% sM: Loaded data for a sequence element
%
% takeMean: True/false for each dimension of sM
%
% nanflag: 'includenan' or  'omitnan'
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the mean dimensions
meanDim = find(takeMean);
nanflag = nanflag(meanDim);

% For each dimension
for m = 1:numel(meanDim)
    
    % Take the mean
    sM = mean( sM, meanDim(m), nanflag{m} );
end

end