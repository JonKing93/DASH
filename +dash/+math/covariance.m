function[XYcov] = covariance(Xdev, Ydev, unbias)

XYcov = unbias .* (Xdev * Ydev');

end