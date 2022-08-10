function[tf] = string(input)
%% dash.is.string  True if an input is a string, cellstring, or char row vector
% ----------
%   tf = dash.is.string(input)
%   Returns true if the input is a string, cellstring, or char row vector.
%   Otherwise, returns false.
% ----------
%   Inputs:
%       input (any data type): The input being tested
%
%   Outputs:
%       tf (scalar logical): True if the input is a string, cellstring, or
%           char row vector. False otherwise
%
% <a href="matlab:dash.doc('dash.is.string')">Documentation Page</a>

tf = false;
if dash.is.str(input) || dash.is.charrow(input)
    tf = true;
end

end