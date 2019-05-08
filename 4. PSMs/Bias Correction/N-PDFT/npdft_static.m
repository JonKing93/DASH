function[X] = npdft_static( Xd, Xt0, Xs0, R, normT, normS )
%% This performs a static npdft. Applies the mapping from a prior npdft to
% bias-correct new values in a deterministic manner.
%
% X = npdft_static( Xd, Xt, Xs, R, normT, normS )
%
% ----- Inputs -----
%
% Xd: Data being bias corrected. (nSamples x nVars)
%
% Xt, Xs, R, normT, normS: See "setupStaticNPDFT.m" for details.
%
% ----- Outputs -----
%
% X: Bias corrected values for Xd.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error Check
errCheck( Xt0, Xs0, Xd )

% Standardize the new data using the normalization from the calibration
% source data. (The input calibration data are already normalized.)
Xd = (Xd - normS(1,:)) ./ normS(2,:);

% Concatenate the standardized datasets. This will allow us to do matrix
% operations with a single line.
X = [Xt0; Xs0; Xd];

% Get indices for each dataset in the concatenated array.
t = 1:size(Xt0,1);
s = max(t)+1:max(t)+size(Xs0,1);
d = max(s)+1:max(s)+size(Xd,1);

% For each iteration
for j = 1:size(R,3)
    
    % Rotate the datasets
    X = X * R(:,:,j);
    
    % For each rotated variable
    for k = 1:N
        
        % Get a static quantile mapping based on the rotated variables from
        % the calibration period
        [tauT, tauS] = setupStaticQM( X(t,:), X(s,:), 'stable' );
        
        % Apply the mapping to the new data and calibration source data
        X([s,d],:) = QM_static( X([s,d],:), X(t,:), tauT, X(s,:), tauS );
    end
    
    % Do the inverse rotation
    X = X * R(:,:,j)';
end

% Extract the new values and restore the standardization from the
% calibration target
X = X(d,:) .* normT(2,:) + normT(1,:);

end

%% Error Checking
function[] = errCheck( Xt, Xs, Xd )

% Check everything is a matrix
if ~ismatrix(Xs) || ~ismatrix(Xt) || ~ismatrix(Xd)
    error('Xs, Xt, and Xd must be matrices.');
end

% All must have the same number of variables
N = size(Xs,2);
if N ~= size(Xt,2) || N ~= size(Xd,2)
    error('Xs, Xt, and Xd must have the same number of columns.');
end

end