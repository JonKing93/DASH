function[varargout] = decomposeEnsemble( Ye )

% Mean
Ymean = mean(Ye,2);
Ydev = Ye - Ymean;

% If only doing mean and deviation
if nargout<3
    varargout = {Ymean, Ydev};
    
% If also returning variance
elseif nargout==3
    Yvar = var(Ye, 0, 2);
    varargout = {Ymean, Ydev, Yvar};
end

end