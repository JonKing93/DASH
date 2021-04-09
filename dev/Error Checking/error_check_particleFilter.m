%% Error check particle filter

Y  = rand(54, 10);
Ye = rand(54, 200, 3);
whichPrior = [1 1 1 2 2 2 3 3 3 3];
R = abs(rand(54,2));
whichR = [1 1 1 1 1 2 2 2 2 2];


%% Check the bayes weights

pf = particleFilter;
pf = pf.estimates(Ye, whichPrior);
pf = pf.uncertainties(R, whichR);
pf = pf.observations(Y);

out = pf.run;

w = NaN(200, 10);
for k = 1:10
    innov = Y(:,k) - Ye(:,:, whichPrior(k));
    Rinv = 1 ./ R(:,whichR(k));
    sse = sum(Rinv .* innov.^2, 'omitnan')';
    
    sse = (-1/2) * sse;
    m = max(sse, [], 1);
    lse = m + log( sum( exp(sse-m), 1) );
    w(:,k) = exp(sse - lse);
end

if ~isequal(out.weights, w)
    error('bad');
end
fprintf('Applied Bayes weights\n');


%% Test diagonalized covariance

pf = particleFilter;
pf = pf.estimates(Ye, whichPrior);

Rcov = cat(3, diag(R(:,1)), diag(R(:,2)));
pf = pf.uncertainties(Rcov, whichR, true);
pf = pf.observations(Y);

out2 = pf.run;

diff = out2.weights - out.weights;
if max(abs(diff),[],'all') > 1E-13
    error('bad');
end
fprintf('Used R covariance\n');


%% weighting selection

pf = particleFilter;
pf = pf.estimates(Ye, whichPrior);
pf = pf.uncertainties(R, whichR);
pf = pf.observations(Y);

pf = pf.weighting('bayes');
out3 = pf.run;

if ~isequal(out, out3)
    error('bad');
end
fprintf('Selected Bayes weights\n');

%% Best N weights

pf = pf.weighting('best', 10);
best = pf.run;

N = sum(best.weights>0, 1);
if any(N~=10)
    error('bad');
end
fprintf('Applied best N weights\n');


%% Update prior

X = rand(140, 200, 3);
pf = pf.prior(X);
up = pf.run;

A = NaN(140,10);
for k = 1:10
    A(:,k) = X(:,:, whichPrior(k)) * up.weights(:,k);
end

diff = A - up.A;
if max(abs(diff),[],'all') > 1E-13
    error('bad');
end
fprintf('Updated prior\n');








