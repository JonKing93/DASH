function[] = dash( M, D, R, locArgs, inflate, F, H, meta)
%
% A = dash( M, D, R, locArgs, inflate, Ye)
% Runs the DA using the tardif method.
%
% A = dash( M, D, R, locArgs, inflate, F, H, meta)
% Runs the DA using a PSM.
%

% Error checking
% errorCheck();

% Get some sizes
nState = size(M,1);
nObs = size(D,1);

% Set the toggle for tardif vs full PSM
fullPSM = true;
if nargin < 7
    fullPSM = false;
end

% Get the weights for covariance localization
if strcmpi( locArgs, 'none')
    w = ones(1, nObs);
else
    w = covLocalization( locArgs{:} );
end

% If doing Tardif...
if ~fullPSM
    
    % Get the trivial PSM
    F = trivialPSM;
    
    % Determine the sampling indices for the Ye
    H = nState + (1:nObs)';
    H = num2cell(H);
    
    % Append Ye to M
    M = [M;Ye];
end

% Now, run the DA
dashDA( M, D, R, w, inflate, F, H, meta );
    
end
    