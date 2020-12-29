X = cat(1, zeros(10,100), ones(5,100), zeros(10,100));

% Linear PSMs
rows = 10:12;
a = linearPSM(rows, 1);

% Defaults
if a.intercept~=0
    error('bad');
end
fprintf('Set default intercept\n');
if numel(a.slopes)~=numel(rows)
    error('bad');
end
fprintf('Propagated slopes\n');

a = linearPSM(rows, 1, 0, 'test');
if ~strcmp(a.name, 'test')
    error('bad');
end
fprintf('Set name \n');



bad = false;
try
    a = linearPSM(rows, 1:7, 0, 'test');
    bad = true;
catch
    fprintf('Caught bad slopes \n');
end
if bad
    error('bad');
end

Y = PSM.estimate(X, a);
if ~isequal(Y, 2*ones(1, size(X,2)))
    error('bad');
end
fprintf('Estimated values\n');

Y = PSM.estimate(X, {a,a});
if ~isequal(Y, 2*ones(2, size(X,2)))
    error('bad');
end
fprintf('Estimated from cell\n');

Y = linearPSM.run(X(rows,:), 1);
if ~isequal(Y, 2*ones(1, size(X,2)))
    error('bad');
end
fprintf('Ran directly\n');