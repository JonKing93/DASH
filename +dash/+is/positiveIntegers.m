function[tf, loc] = positiveIntegers(X)
%% dash.is.positiveIntegers  Test if a numeric array consists entirely of positive integers
% ----------
%   tf = dash.is.positiveIntegers(X)
%   Return true if X consists entirely of positive integers. Return false
%   otherwise.
%
%   [tf, loc] = dash.is.positiveIntegers(X)
%   If X is not all positive integers, also return the index of the first
%   element that is not a positive integer.
% ----------
%   Inputs:
%       X (numeric array): The array being tested
%
%   Outputs:
%       tf (scalar logical): True if X consists entirely of positive
%           integers. False otherwise
%       loc ([] | scalar linear index): If X is positive integers, an empty
%           array. Otherwise, the index of the first element that is not a
%           positive integer
%
% <a href="matlab:dash.doc('dash.is.positiveIntegers')">Documentation Page</a>

toosmall = X < 1;

if any(toosmall, 'all')
    tf = false;
    loc = find(toosmall,1);
else
    [tf, loc] = dash.is.integers(X);
end

end
