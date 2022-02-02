function[] = integers(X, name, header)
%% dash.assert.integers  Throw error if numeric array does not consist entirely of integers
% ----------
%   dash.assert.integers(X)
%   Throws an error if the input is not an array consisting only of
%   integers. Here, "integer" does not refer to the underlying data type of
%   the array, but rather the values of the array elements. An array of
%   type "double" will pass the assertion if all elements are integers.
%   Values of NaN, Inf, and -Inf are not considered integers here.
%
%   dash.assert.integers(X, name, header)
%   Customize thrown error message and ID.
% ----------
%   Inputs:
%       X (numeric array): The numeric array being tested
%       name (string scalar): The name of the input to use in error messages
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('dash.assert.integers')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:integers";
end

% Test integers
[isintegers, bad] = dash.is.integers(X);

% Informative error if not integers
if ~isintegers
    if ~isscalar(name)
        name = sprintf('Element %.f of %s', bad, name);
    end
    id = sprintf('%s:inputNotIntegers', header);
    error(id, '%s (%f) is not an integer.', name, X(bad));
end

end