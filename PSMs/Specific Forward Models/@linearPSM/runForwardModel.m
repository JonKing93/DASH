function[Ye, R] = runForwardModel( obj, M, ~, ~ )
% Runs a linear PSM
%
% [Ye, R] = obj.runForwardModel( M )

% Preallocate
nVar = numel(obj.slope);
var = NaN( nVar, size(M,2) );

% Obtain any variables that are means of multiple state elements
for v = 1:nVar
    var(v,:) = mean(  M(obj.Hlim(v,1):obj.Hlim(v,2), :), 1 );
end

% Calculate Ye and R
Ye = linearPSM.linearModel( var, obj.slopes, obj.intercept );
R = [];

end