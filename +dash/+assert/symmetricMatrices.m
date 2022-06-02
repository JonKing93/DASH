function[] = symmetricMatrices(X, name, header)
%% dash.assert.symmetricMatrices  Throw error if elements along the third dimension are not symmetric matrices
% ----------
%   dash.assert.symmetricMatrices(X)
%   Given a numeric 3D array, checks that each each element along the third
%   dimension is a symmetric matrix. Throws an error if not. NaN elements
%   are replaced with a -999 placeholder to allow symmetric comparison of
%   NaN elements. If the placement of all NaN elements is symmetric, then
%   the input will pass the assertion.
%
%   dash.assert.symmetricMatrices(X, name, header)
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

% Infill NaN elements
nans = isnan(X);
X(nans) = -999;

% Check each element along the third dimension is a symmetric matrix
nPages = size(X, 3);
for k = 1:nPages
    if ~issymmetric(X(:,:,k))

        % Throw error if not
        id = sprintf('%s:inputNotSymmetricMatrices', header);
        if k==1
            ME = MException(id, '%s must be a symmetric matrix', name);
        else
            ME = MException(id, ['Each element along the third dimension of ',...
                '%s must be a symmetric matrix. However, element %.f is not ',...
                'a symmetric matrix.'], name, k);
        end
        throwAsCaller(ME);
    end
end

end