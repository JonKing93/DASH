function[hasError] = checkYe( Ye, nEns )
%% Error checks Ye output from a PSM

% Initialize the error flag
hasError = false;

% Check that the size is correct
if ~isequal( size(Ye), [1, nEns] )
    fprintf( ['PSM %0.f returned Ye with an incorrect size in time step %0.f.\n', ...
        'Dash will not use observation %0.f to update time step %0.f.\n\n'], d, t, d, t);
    hasError = true;

% Check that the output is numeric and real
elseif ~isnumeric(Ye) || any(~isreal(Ye))
    fprintf( ['PSM %0.f returned Ye with that are not numeric or are complex-valued in time step %0.f.\n', ...
        'Dash will not use observation %0.f to update time step %0.f.\n\n'], d,t,d,t);
    hasError = true;

% Check that there are no NaN
elseif any(isnan(Ye))
    fprintf( ['PSM %0.f returned Ye with NaN in time step %0.f.\n', ...
        'Dash will not use observation %0.f to update time step %0.f.\n\n'], d,t,d,t);
    hasError = true;

% Check if there are Inf
elseif any(isinf(Ye))
    fprintf( ['PSM %0.f returned Ye with Inf or -Inf in time step %0.f.\n', ...
        'Dash will not use observation %0.f to update time step %0.f.\n\n'], d,t,d,t);
    hasError = true;

% Check if the values are all the same. (This would explode the Kalman Gain
% to Inf)
elseif numel(unique(Ye))==1
    fprintf( ['PSM %0.f returned Ye with the same value  in time step %0.f.\n', ...
        'This is not allowed becuase it would magnify the Kalman Gain to infinity.\n',...
        'Dash will not use observation %0.f to update time step %0.f.\n\n'], d,t,d,t);
    hasError = true;
end

end
