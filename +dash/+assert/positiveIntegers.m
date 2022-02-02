function[] = positiveIntegers(X, name, header)
%% dash.assert.postiveIntegers  Throw error if numeric array does not consist entirely of positive integers
% ----------
%   dash.assert.integers(X)
%   Throws an error if the input is not an array consisting only of positive
%   integers. Here, "integer" does not refer to the underlying data type of
%   the array, but rather the values of the array elements. An array of
%   type "double" will pass the assertion if all elements are positive integers.
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
% <a href="matlab:dash.doc('dash.assert.positiveIntegers')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:positiveIntegers";
end

% Test integers
[isvalid, bad] = dash.is.positiveIntegers(X);

% Informative error if failed
if ~isvalid
    id = sprintf('%s:inputNotPositiveIntegers', header);
    error(id, 'Element %.f of %s (%f) is not a positive integer.', bad, name, X(bad));
end

end