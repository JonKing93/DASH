function[tf] = strflag(input)
%% dash.is.strflag  True for string scalar or char row vector.
% ----------
%   dash.is.strflag(input) 
%   Returns true if input is a string scalar or char row vector and false otherwise.
% ----------
%   Inputs:
%       input: The input being tested
%
%   Outputs:
%       tf (scalar logical): True if input is a string scalar or char row vector
%
%    <a href="matlab: dash.doc('dash.is.strflag')">Documentation Page</a>

if (ischar(input) && isrow(input)) || (isstring(input) && isscalar(input))
    tf = true;
else
    tf = false;
end

end