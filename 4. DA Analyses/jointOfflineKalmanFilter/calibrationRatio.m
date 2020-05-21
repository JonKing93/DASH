function[calibRatio] = calibrationRatio( D, Ymean, Kdenom )
calibRatio = (D - Ymean).^2 ./ diag(Kdenom);
end