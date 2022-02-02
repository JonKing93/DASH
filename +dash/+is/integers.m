function[tf, loc] = integers(X)
%% dash.is.integers  Test if a numeric array consists of integers
% ----------
%   tf = dash.is.integers(X)
%   Returns true if the input consists entirely of integers. Returns false
%   otherwise.
%
%   [tf, loc] = dash.is.integers(X)
%   If the array does not consist entirely of integers, returns the index
%   of the first non-integer element.
% ----------
%   Inputs:
%       X (numeric array): The numeric array being tested
%
%   Outputs:
%       tf (scalar logical): True if the array consists entirely of 
%           integers. Otherwise false.
%       loc ([] | scalar linear index): If the array is integers, an empty
%           array. If the array is not all integers, the index of the first
%           non-integer element.
%
% <a href="matlab:dash.doc('dash.is.integers')">Documentation Page</a>

notinteger = mod(X,1)~=0;

if any(notinteger, 'all')
    tf = false;
    loc = find(notinteger,1);
else
    tf = true;
    loc = [];
end

end