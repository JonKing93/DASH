function[weights] = pfWeights( sse, N )
% Compute particle filter weights
%
% weights = dash.pfWeights( sse, NaN )
% Uses a probabilistic weighting
%
% weights = dash.pfWeights( sse, N )
% Does equal weighting of the best N particles
%
% ----- Inputs -----
%
% sse: A matrix of particle sum of squared errors (nEns x nTime)
%
% N: A scalar integer.
%
% ----- Outputs -----
% 
% weights: The weights for each particle (nEns x nTime)

% Probabilistic weights
if isnan(N)
    weights = normexp( (-1/2) * sse );
    
% Or best N particles
else
    [nEns, nTime] = size(sse);
    weights = zeros( nEns, nTime );
    for t = 1:nTime
        [~,rank] = sort( sse(:,t) );
        best = rank( 1:N );
        weights( best, t ) = 1/N;
    end
end

end