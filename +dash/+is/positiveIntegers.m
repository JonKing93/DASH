function[tf] = positiveIntegers(X)
%% dash.is.positiveInteger  Tests if values in a numeric array are positive integers
% ----------
%   tf = dash.is.positiveIntegers(X)
%   Returns true if X is a numeric array of positive integers. Otherwise,
%   returns false.
% ----------
%   Inputs:
%       X: The array being tested
%
%   Outputs:
%       tf (scalar logical): True if X is a numeric array that strictly
%           consists of positive integers. False otherwise.
%
% <a href="matlab:dash.doc('dash.is.positiveIntegers')">Documentation Page</a>

if ~isnumeric(X) || any(X<1, 'all') || any(mod(X,1)~=0, 'all')
    tf = false;
else
    tf = true;
end

end