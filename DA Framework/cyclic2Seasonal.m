function[Dseas] = cyclic2Seasonal(D, R, obSeason)
% Converts D recorded in cyclic time to seasonal time.
%
% D: A set of observations in cyclic time.
%
% R: A set of observational uncertainties in cyclic time.
%
% obSeason

% Get some sizes
nTime = length(sTimeM);
nObs = size(D,1);
nSeas = size(obSeason,2);

% Get seasonality information
% !!!!!! This line is repeated later in doffENSRF
[sObs, ~, sFinal, nPrev] = seasonSetup(obSeason);

% Ensure that the length of time is an exact multiple of the number of
% seasons. Check that time starts on the first season.
if mod(nTime, nSeas) ~= 0
    error('The total number of time steps must be an exact multiple of the number of seasons.');
end

% Preallocate the seasonal D and R matrices
Dseas = NaN( nObs, nTime );
Rseas = NaN( nObs, nTime );

% For each observational set
for s = 1:length(sFinal)
    
    % Get the observations that are in this set
    currSet = (sObs == s);
    
    % Check that the first cycle does not contain an average that extends
    % out of the time domain.
    if nPrev(s) > sFinal(s)
        skip = 1;
    else
        skip = 0;
    end    
    
    % Fill in observations on the final recording season for this set,
    % skipping the first cycle if necessary
    Dseas(currSet, sFinal+(skip*nSeas):nSeas:end) = D(currSet, 1+skip:end);
    Rseas(currSet, sFinal+(skip*nSeas):nSeas:end) = R(currSet, 1+skip:end);
end

end