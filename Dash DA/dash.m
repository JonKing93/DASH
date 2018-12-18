function[varargout] = dash( M, D, R, w, inflate, F, H)
%
% A = dash( M, D, R, locArgs, inflate, Ye)
% Runs the DA using the tardif method.
%
% A = dash( M, D, R, locArgs, inflate, F, H)
% Runs the DA using a PSM.
%
% A = dash( M, D, [], ...)
% Dynamically generates R from forward models.
%
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty. (nObs x nTime) OR [] for dynamic generation
%       Matrix of size (nObs x nTime): Specify R
%       []: Dynamically generate R from forward models and Ye
%
% w: Covariance localization weights. Leave empty for no localization.
%
% inflate: A scalar inflation factor. Leave empty for no inflation.
%
% Ye: Model estimates. (nObs x nEns)
%
% F: A proxy system model of the "PSM" class
%
% H: A cell of state variable indices needed to run the forward model for
%      each site. {nObs x 1}
%
% ----- Outputs -----
%
% A: Output Analysis

% Error checking
% errorCheck();

% Get some sizes
nState = size(M,1);
nObs = size(D,1);

% Set the toggle for tardif vs full PSM
fullPSM = true;
if ~isa(F, 'PSM')
    fullPSM = false;
    Ye = F;
end

% Get the defualt weights for covariance localization
if isempty(w)
    w = ones(nState, nObs);
end

% If doing Tardif...
if ~fullPSM
    
    % Get the trivial PSM. Just going to return the Ye values in the
    % appended state as the PSM output.
    F = trivialPSM;
    
    % Determine the sampling indices for the Ye
    H = nState + (1:nObs)';
    H = num2cell(H);
    
    % Append Ye to M
    M = [M;Ye];
end

% Now, run the DA
A = dashDA( M, D, R, w, inflate, F, H );

% If doing tardif
if ~fullPSM
    
    % Unappend the Ye
    nState = size(M,1) - size(Ye,1);
    
    Ya = A(nState+1:end,:,:);
    A = A(1:nState,:,:);
    
    % Set the output
    varargout = {A, Ya};
else
    varargout = {A};
end

end