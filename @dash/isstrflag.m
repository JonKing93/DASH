function[tf] = isstrflag( input )
%% Tests if an input is a character row vector or string scalar.
%
% tf = isstrflag( input )
%
% ----- Inputs -----
%
% input: The input being tested.
%
% ----- Outputs -----
%
% tf: Whether the input is a flag. A scalar logical.

tf = false;
if ischar(input) && isrow(input)
    tf = true;
elseif isstring(input) && isscalar(input)
    tf = true;
end

end