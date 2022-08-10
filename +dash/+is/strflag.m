function[tf] = strflag(input)
%% dash.is.strflag  True for string scalar or char row vector.
% ----------
%   dash.is.strflag(input) 
%   Returns true if input is a string scalar or char row vector and false otherwise.
% ----------
%   Inputs:
%       input (any data type): The input being tested
%
%   Outputs:
%       tf (scalar logical): True if input is a string scalar or char row vector
%
% <a href="matlab:dash.doc('dash.is.strflag')">Documentation Page</a>

tf = false;
if (isscalar(input) && dash.is.str(input)) || dash.is.charrow(input)
    tf = true;
end

end