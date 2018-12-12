function[w] = covWeights( covArgs )

% Use unadjusted covariance
if strcmpi( covArgs{1}, 'none' )
    w = 1; %ones(nState, nObs);

% Doing covariance inflation
elseif strcmpi( covArgs{1}, 'inflate' )
    factor = covArgs{2};
    w = factor * ones(nState, nObs);
    
% Covariance localizaton
elseif strcmpi( covArgs{1}, 'localize' )
    w = covLocalization( covArgs{2:end} );
    
% Anything else...
else
    error('Unrecognized covariance adjustment.');
end

end