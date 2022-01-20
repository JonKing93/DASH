function[] = integers(input, name, header)
%% dash.assert.integers  Throw error if input does not consist of integers
% ----------
%   dash.assert.integers(input)
%   Throws an error if the input is not an array consisting only of
%   integers. Here, "integer" does not refer to the underlying data type of
%   the array, but rather the values of the array elements. An array of
%   type "double" will pass the assertion if all elements are integers.
%   Values of NaN, Inf, and -Inf are not considered integers here.
%
%   dash.assert.integers(input, name, header)
%   Customize thrown error message and ID.
% ----------
%   Inputs:
%       input (numeric array): The input being tested
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

% Informative error if not an integer
notinteger = mod(input,1)~=0;
if any(notinteger,'all')
    bad = find(notinteger, 1);
    id = sprintf('%s:inputNotIntegers', header);
    error(id, 'Element %.f of %s (%s) is not an integer.', bad, name, input(bad));
end

end