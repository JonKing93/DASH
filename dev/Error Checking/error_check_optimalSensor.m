%% Error check optimal sensor

X = rand(140,10);
Ye = rand(54, 10);
R = abs(rand(54, 1));

% Run using estimates
os = optimalSensor;
os = os.prior(X);
os = os.estimates(Ye, R);
os = os.metric('mean', [1 2], [3 4]);

[best, expVar] = os.run(2);
