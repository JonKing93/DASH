function[] = positiveDiagonals(X, name, header)
%% dash.assert.positiveDiagonals  Throw error if diagonals of matrices along the third dimension are not positive
% ----------
%   dash.assert.positiveDiagonals(X)
%   Given a numeric 3D array, checks that the diagonals of each matrix
%   along the third dimension are positive. Also allows NaN elements along
%   the diagonals. Throws an error if not. The method assumes that the
%   input matrices are covariance matrices, so thrown error messages will
%   refer to the matrices as covariances.
%
%   dash.assert.positiveDiagonals(X, name, header)
%   Customize error messages and IDs
% ----------
%   Inputs:
%       X (numeric 3D array): The input being checked
%       name (string scalar): The name of the input
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('dash.assert.positiveDiagonals')">Documentation Page</a>

% Defaults
if ~exist('name','var')
    name = 'the input';
end
if ~exist('header','var')
    header = "DASH:assert:symmetricMatrices";
end

% Check the diagonal of each matrix consists of positive or NaN elements
nPages = size(X, 3);
for k = 1:nPages
    Xd = diag(X(:,:,k));
    allowed = Xd>0 | isnan(Xd);

    % Throw error if not valid
    bad = find(~allowed, 1);
    if ~isempty(bad)
        id = sprintf('%s:negativeDiagonals', header);
        if k == 1
            ME = MException(id, ['Variances (the diagonal elements of %s) ',...
                'must be positive. However, variance %.f is not positive.'], ...
                name, bad);
        else
            ME = MException(id, ['Variances (the diagonal elements of each ',...
                'covariance matrix along the third dimension of %s) must be ',...
                'positive. However, variance %.f of covariance matrix %.f is ',...
                'not positive.'], name, bad, k);
        end
        throwAsCaller(ME);
    end
end

end