function[X] = npdft_static( Xt, Xs, Xd, R, normT, normS )
%% This performs a static npdft. Applies the mapping from a prior npdft to
% bias-correct new values in a deterministic manner.
%
% X = npdft_static( Xt, Xs, Xd, R, normT, normS )
%
% ----- Inputs -----
%
% Xt: Saved target data from an initial Npdft
%
% Xs: Saved source data from an initial Npdft
%
% Xd: The values being bias-corrected
%
% R: Saved rotation matrices from initial npdft
%
% normT: The normalization used on Xt.
%
% normS: The normalization used on Xs.
%
% ----- Outputs -----
%
% X: Bias corrected values for Xd.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check everything is a matrix
if ~ismatrix(Xs) || ~ismatrix(Xt) || ~ismatrix(Xd)
    error('Xs, Xt, and Xd must be matrices.');
end

% All must have the same number of variables
N = size(Xs,2);
if N ~= size(Xt,2) || N ~= size(Xd,2)
    error('Xs, Xt, and Xd must have the same number of columns.');
end

% Get indices to concatenate all the data
t = 1:size(Xt,1);
s = max(t)+1:max(t)+size(Xs,1);
d = max(s)+1:max(s)+size(Xd,1);

% Concatenate everything
X = [Xt;Xs;Xd];

% Standardize the matrices
X(t,:) = ( X(t,:) - normT(1,:) ) ./ normT(2,:);
X([s,d],:) = ( X([s,d],:) - normS(1,:) ) ./ normS(2,:);

% For each iteration
for j = 1:size(R,3)
    
    % Rotate the datasets
    X = X * R(:,:,j);
    
    % For each variable
    for k = 1:N
        
        % Do a static quantile mapping for Xd
        X(d,k) = quantMap( X(t,k), X(s,k), X(d,k) );
        
        % Do a standard quantile mapping for Xs
        X(s,k) = quantMap( X(t,k), X(s,k) );
    end
    % Do the inverse rotation
    X = X * R(:,:,j)';
end

% Extract the Xd values and restore the mean and std from the target
X = X(d,:) .* normT(2,:) + normT(1,:);

end