function[output] = ensrf()

% Decompose the ensembles
[Mmean, Mdev] = dash.decompose(M);
[Ymean, Ydev] = dash.decompose(Y);

% Get the covariance matrices
[Knum, Ycov] = ensrfCovariance( Mdev, Ydev, w, yloc );

% Do the updates
output = ensrfUpdates( Mmean, Mdev, D, R, Ymean, Ydev, Knum, Ycov, ...
                       returnMean, returnVar, percentiles, returnDevs, showProgress );
                   
end