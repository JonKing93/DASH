function[] = checkYeValues( Ye, nEns )
%% Error checks Ye output from a PSM

% Check that the size is correct
if ~isequal( size(Ye), [1, nEns] )
    error('PSM returned Ye with incorrect size.');

% Check that the output is numeric and real
elseif ~isnumeric(Ye) || any(~isreal(Ye))
    error('PSM returned Ye that were not numeric or were complex valued.');

% Check that there are no NaN
elseif any(isnan(Ye))
    error('PSM returned Ye with NaN values.');

% Check if there are Inf
elseif any(isinf(Ye))
    error('PSM returned Ye with infinite values.');

% Check if the values are all the same. (This would explode the Kalman Gain
% to Inf)
elseif numel(unique(Ye))==1
    error( 'PSM returned Ye values that are all identical.\n(This would magnify the Kalman Gain to infinity).' );
end

end
