function[] = covariances(X, name, header)
%% dash.assert.covariances  Throw error if matrices along the third dimension are not covariances
% ----------
%   dash.assert.covariances(X)
%   Given a numeric 3D array, checks that each matrix along the third
%   dimension is a valid covariance matrix. Covariance matrices must be
%   symmetric with positive diagonals (variances). NaN elements are allowed
%   as long as they are distributed symmetrically. Uses a -999 placeholder
%   to allow symmetric comparison of NaN elements. NaN elements are also
%   allowed along the diagonals. If the matrices do not meet these 
%   criteria, throws an error.
%
%   dash.assert.covariances(X, name, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       X (numeric 3D array): The input being checked
%       name (string scalar): The name of the input
%       header (string scalar): Header for thrown error IDs.
%
% <a href="matlab:dash.doc('dash.assert.symmetricMatrices')">Documentation Page</a>

% Defaults
if ~exist('name','var')
    name = 'the input';
end
if ~exist('header','var')
    header = "DASH:assert:symmetricMatrices";
end

% Check each matrix is symmetric with positive diagonals
nPages = size(X, 3);
for k = 1:nPages
    try
        dash.assert.symmetricMatrices(X, name, header);
        dash.assert.positiveDiagonals(X, name, header);
      
    % Minimize error stacks
    catch ME
        throwAsCaller(ME);
    end
end

end