% %% Download
% 
% % Delete existing packages
% psmNames = ["BAYSPAR","BAYSPLINE","BAYMAG","BAYFOX","PRYSM","VSLITE"];
% repoNames = ["BAYSPAR","BAYSPLINE","BAYMAG","bayfoxm","PRYSM","VSLite"];
% 
% for n = 1:numel(psmNames)
%     try
%         rmdir( psmNames(n), 's' );
%     catch
%     end
% end
% 
% % Download
% try
%     for n = 1:numel(psmNames)
%         PSM.download(psmNames(n));
%     end
% catch
%     error('Failed to download %s', psmNames(n));
% end
% 
% % Check exists
% folders = dir;
% names = string( {folders(:).name} );
% use = [folders.isdir];
% names = names(use);
% 
% if any(~ismember(repoNames, names))
%     error('Missing downloaded PSM');
% end
fprintf('Downloaded PSMs\n');

%% PSM rows

X = [1:10;101:110;201:210];
X = cat(3, X, X+1000);

try
    p1 = PSM.linear(-2,1,1);
    error('bad');
catch
    fprintf('Caught bad index\n');
end

try
    p1 = PSM.linear(4,1,1);
    Ye = PSM.estimate(X, p1);
    error('bad');
catch
    fprintf('Caught large row\n');
end

% Basic estimate
rows = [2;3];
p1 = PSM.linear(rows,2,1);
Ye1 = PSM.estimate(X, p1);
Xpsm = X(rows,:,:);
if ~isequal(sum(2*X(rows,:,:),1)+1, Ye1)
    error('bad');
end
fprintf('Ran estimator\n');

% R estimation
p2 = PSM.bayfox([1;2], 'all');
rng('default');
[Ye2, R2] = PSM.estimate(X, p2, true);
fprintf('Estimated R values\n');

% Mixed R estimation
F = {p1; p2};
rng('default');
[Ye12, R12] = PSM.estimate(X, F, true);
if ~isequal(Ye1, Ye12(1,:,:))
    error('bad');
elseif ~isequal(Ye2, Ye12(2,:,:))
    error('bad');
elseif ~all(isnan(R12(1,:,:)), 'all')
    error('bad');
elseif ~isequal(R2, R12(2,:,:))
    error('bad');
end
fprintf('Estimated values and R for mixed PSMs');

% Mixed columns
rows = [1 1 1 2 2 2 3 3 3 3];
p3 = PSM.linear(rows, 1, 0);
Ye1 = PSM.estimate(X, p3);
Ye2 = cat(2, X(1,1:3,:), X(2,4:6,:), X(3,7:10,:));
if ~isequal(Ye1, Ye2)
    error('bad');
end
fprintf('Used different rows for different ensemble members\n');


%% Individual PSMs

X = rand(155, 100);

% Linear PSM
p = PSM.linear((1:5)', 1:5, 1);
Ye1 = PSM.estimate(X, p, true);
Ye2 = sum(X(1:5,:).*(1:5)',1)+1;
if ~isequal(Ye1, Ye2)
    error('bad');
end
fprintf('Ran linear PSM\n');

% VS-Lite
p = PSM.vslite((1:24)', 30, 0, 1, 0, 1, {});
Ye1 = PSM.estimate(X, p);
Ye2 = VSLite_v2_3(1, 100, 30, 0, 1, 0, 1, X(1:12,:), X(13:24,:));
if ~isequal(Ye1, Ye2)
    error('bad');
end
fprintf('Ran VS-Lite PSM\n');

% Bayfox
p = PSM.bayfox([1;2], 'all');
rng('default');
[Ye1, R1] = PSM.estimate(X, p);
rng('default');
Yy = bayfox_forward(X(1,:), X(2,:), 'all');
Ye2 = mean(Yy,2)';
R2 = var(Yy, [], 2)';
if ~isequal(Ye1, Ye2)
    error('bad');
elseif ~isequal(R1, R2)
    error('bad');
end
fprintf('Ran BayFOX\n');

% Baymag
p = PSM.baymag(1, 1, .5, .5, 7, 1, 'all');
rng('default');
[Ye1, R1] = PSM.estimate(X, p, true);
rng('default');
Yy = baymag_forward_ln(1, X(1,:), .5, .5, 7, 1, 'all');
Ye2 = mean(Yy,2)';
R2 = var(Yy, [], 2)';
if ~isequal(Ye1, Ye2)
    error('bad');
elseif ~isequal(R1, R2)
    error('bad');
end
fprintf('Ran BayMAG\n');

% BaySpar
p = PSM.bayspar(1, 31, 129);
rng('default');
[Ye1, R1] = PSM.estimate(X, p, true);
rng('default');
Yy = TEX_forward(31, 129, X(1,:));
Ye2 = mean(Yy,2)';
R2 = var(Yy, [], 2)';
if ~isequal(Ye1, Ye2)
    error('bad');
elseif ~isequal(R1, R2)
    error('bad');
end
fprintf('Ran BaySPAR\n');

% Bayspline
p = PSM.bayspline(1);
rng('default');
[Ye1, R1] = PSM.estimate(X, p, true);
rng('default');
Yy = UK_forward(X(1,:));
Ye2 = mean(Yy,2)';
R2 = var(Yy, [], 2)';
if ~isequal(Ye1, Ye2)
    error('bad');
elseif ~isequal(R1, R2)
    error('bad');
end
fprintf('Ran BaySPAR\n');

% Prysm Cellulose
p = PSM.prysmCellulose([1;2;3], 0, 0, 0, 'Evans', false);
Ye1 = PSM.estimate(X, p, true);
fprintf('Ran Prysm Cellulose\n');

% Prysm coral
p = PSM.prysmCoral([1;2], true, 30, 120, "Default");
PSM.estimate(X, p, true);
fprintf('Ran PRYSM Coral\n');

% Prysm ice core
p = PSM.prysmIcecore(1, 5);
[Ye, R] = PSM.estimate(X, p, true);
fprintf('Ran PRYSM Ice core\n');

% Prysm speleothem
% p = prysmSpeleothem([1;2], 1/12, "Adv-Disp", 1, 1);
% Ye = PSM.estimate(X, p, true);
% fprintf('Ran PRYSM speleothem\n');

