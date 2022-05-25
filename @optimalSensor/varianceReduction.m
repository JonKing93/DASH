function[deltaVar] = varianceReduction(Jdev, Ydev, R, unbias)
%% optimalSensor.varianceReduction  Evaluates the reduction of variance for sites in an optimal sensor

Yvar = dash.math.variance(Ydev, unbias);
deltaVar = (unbias * Ydev * Jdev').^2 ./ (Yvar + R);

end